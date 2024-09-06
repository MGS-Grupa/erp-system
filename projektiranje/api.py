from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'
db = SQLAlchemy(app)

@app.route('/')
def index():
    return jsonify({"message": "Welcome to the projektiranje module!"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5004)
