import pytest
from flask import Flask


@pytest.fixture
def app():
    app = Flask(__name__)

    @app.route('/')
    def index():
        return "Hello World"

    return app


@pytest.fixture
def client(app):
    return app.test_client()


def test_index(client):
    response = client.get('/')
    assert response.status_code == 200
    assert response.data.decode('utf-8') == "Hello World"