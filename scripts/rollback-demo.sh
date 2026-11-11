#!/usr/bin/env bash
# Live rollback demo for the Helm release "voting": ship a bad release on purpose, show it fail,
# roll back with helm, prove the app is healthy again.
#
# Run on the k3s server (after the app is deployed):
#   sudo REGISTRY=ghcr.io/<github-owner> ./rollback-demo.sh
set -uo pipefail

RELEASE=${RELEASE:-voting}
CHART=${CHART:-/opt/voting-app/helm/voting-app}
REGISTRY=${REGISTRY:?set REGISTRY, e.g. ghcr.io/<github-owner> (lowercase)}
VOTE_URL=${VOTE_URL:-http://127.0.0.1:31000}
export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}

step() { printf '\n=== %s\n' "$*"; }

good_rev=$(helm history "$RELEASE" -o json | python3 -c '
import json, sys
deployed = [r["revision"] for r in json.load(sys.stdin) if r["status"] == "deployed"]
print(deployed[-1])')

step "1. Healthy release: revision $good_rev"
helm history "$RELEASE" --max 5
curl -fsS -o /dev/null "$VOTE_URL/" && echo "vote page answers"

step "2. Ship a bad release on purpose (an image tag that does not exist)"
helm upgrade "$RELEASE" "$CHART" --reset-then-reuse-values \
  --set image.registry="$REGISTRY" --set image.tag="does-not-exist" \
  --wait --timeout 90s
echo "(helm exit code $? - a failure here is the expected result)"

step "3. Show the failure"
helm history "$RELEASE" --max 5
kubectl get pods
echo
echo "The old pods keep serving because the rolling update never removed them:"
curl -fsS -o /dev/null "$VOTE_URL/" && echo "vote page still answers"

step "4. Roll back to revision $good_rev"
helm rollback "$RELEASE" "$good_rev" --wait --timeout 3m || exit 1

step "5. Verify the rollback"
helm history "$RELEASE" --max 5
kubectl get pods
kubectl get deploy -o custom-columns=NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image,READY:.status.readyReplicas
curl -fsS -o /dev/null "$VOTE_URL/" && echo "vote page answers"
helm test "$RELEASE" --timeout 2m && echo "ROLLBACK VERIFIED"
