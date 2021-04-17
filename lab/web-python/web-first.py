#!/usr/bin/env python3

from flask import Flask

app = Flask(__name__)

@app.route("/")
def index():
    return "Congratulations, it's a web app v0.1!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)

