from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route("/", methods=["GET"])
def simple_time_service():
    client_ip = request.headers.get("X-Forwarded-For", request.remote_addr)
    response = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "ip": client_ip,
    }
    return jsonify(response)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
