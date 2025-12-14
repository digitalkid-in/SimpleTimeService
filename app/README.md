# SimpleTimeService

A simple python based tool to display a user's current timestamp and IP Address in the web browser.

## Dev Setup

Clone the code locally and run the following commands in your terminal:

## Project Structure

```
SimpleTimeService/
├── app/                          # Local development
│   ├── Dockerfile               # Simple Flask server
│   ├── app.py                   # Flask app
│   └── requirements.txt         # Only flask
```

## Docker Setup

To Build and Run the application using the Dockerfile.

```bash

#To Pull the Docker Image
docker pull digitalkid/simple-time-service:latest

#To run the application
docker run -p 8000:8000 simple-time-service

```

Open http://localhost:8000 (or http://127.0.0.1:8000) in your browser.  
If you're running the app in Docker, make sure port 8000 is forwarded (for example: docker run -p 8000:8000 simple-time-service).


## Local Development

Run the Flask app locally using Docker:

```bash
cd app
docker build -t simple-time-service-local .
docker run -p 8000:8000 simple-time-service-local

```

Or run directly with Python:

```bash
cd app
pip install -r requirements.txt
python app.py
```