from flask import Flask, render_template
import pyjokes
from emoji import emojize

app = Flask(__name__)


@app.route('/')
def index():
    joke = pyjokes.get_joke()
    laughing_emoji = emojize(":rolling_on_the_floor_laughing:")
    return render_template('index.html', joke=joke, laughing_emoji=laughing_emoji)
