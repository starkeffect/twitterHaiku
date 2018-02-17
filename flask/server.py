from flask import Flask
import json

app = Flask(__name__)

def markov():
    #get twitter feed
    #create markov chain
    return [{"this": "that", "foo": "bar"}]

@app.route("/")
def root():
    return "Welcome to the root, check out <a href=\"/json\">json</a> for more..."

@app.route("/json")
def get_json():
    return json.dumps(markov())

@app.route("/isnew/")
def isnew():
    return "False"
