"""Unit tests for the vote app. Redis is replaced by a fake, so no services are needed."""
import json
import os
import sys

import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
import app as vote_app  # noqa: E402


class FakeRedis:
    def __init__(self):
        self.pushed = []

    def rpush(self, key, value):
        self.pushed.append((key, value))


@pytest.fixture()
def client(monkeypatch):
    fake = FakeRedis()
    monkeypatch.setattr(vote_app, "get_redis", lambda: fake)
    vote_app.app.config["TESTING"] = True
    with vote_app.app.test_client() as c:
        c.fake_redis = fake
        yield c


def test_home_page_loads_and_sets_voter_cookie(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert "voter_id" in resp.headers.get("Set-Cookie", "")


def test_home_page_shows_both_options(client):
    body = client.get("/").get_data(as_text=True)
    assert vote_app.option_a in body
    assert vote_app.option_b in body


def test_vote_is_queued_in_redis(client):
    resp = client.post("/", data={"vote": "a"})
    assert resp.status_code == 200
    assert len(client.fake_redis.pushed) == 1
    key, value = client.fake_redis.pushed[0]
    assert key == "votes"
    payload = json.loads(value)
    assert payload["vote"] == "a"
    assert payload["voter_id"]


def test_get_does_not_touch_redis(client):
    client.get("/")
    assert client.fake_redis.pushed == []