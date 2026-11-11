#!/usr/bin/env bash
# End-to-end smoke test: open the vote page, cast a vote, wait until the worker has stored it
# in Postgres, then open the result page.
#
#   VOTE_URL=http://localhost:8082 RESULT_URL=http://localhost:8081 \
#   DB_COUNT_CMD="docker compose exec -T db psql -U postgres -tAc 'select count(*) from votes'" \
#   scripts/smoke-test.sh
#
# DB_COUNT_CMD is optional; without it only the two pages are checked.
set -euo pipefail

VOTE_URL=${VOTE_URL:?set VOTE_URL, e.g. http://localhost:8082}
RESULT_URL=${RESULT_URL:?set RESULT_URL, e.g. http://localhost:8081}
jar=$(mktemp)
trap 'rm -f "$jar"' EXIT

echo "1/4 vote page answers"
curl -fsS --retry 20 --retry-delay 3 --retry-connrefused -c "$jar" -o /dev/null "$VOTE_URL/"

echo "2/4 cast a vote"
curl -fsS -b "$jar" -c "$jar" -X POST --data "vote=a" -o /dev/null "$VOTE_URL/"

if [ -n "${DB_COUNT_CMD:-}" ]; then
  echo "3/4 the worker moves the vote from redis to postgres"
  for i in $(seq 1 30); do
    n=$(bash -c "$DB_COUNT_CMD" 2>/dev/null | tr -d '[:space:]' || true)
    if [ "${n:-0}" -ge 1 ] 2>/dev/null; then
      echo "    stored: $n vote(s) in the database"
      break
    fi
    if [ "$i" -eq 30 ]; then
      echo "the vote never reached the database" >&2
      exit 1
    fi
    sleep 2
  done
else
  echo "3/4 skipped (DB_COUNT_CMD not set)"
fi

echo "4/4 result page answers"
curl -fsS --retry 10 --retry-delay 3 -o /dev/null "$RESULT_URL/"
echo "smoke test passed"
