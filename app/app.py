
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello! My Python DevOps application is running."

@app.route("/health")
def health():
    return {"status": "healthy"}
