# Use official slim Python image
FROM python:3.12-slim

# Install system dependencies and ffmpeg
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install yt-dlp
RUN pip install --upgrade pip yt-dlp

# Set working directory
WORKDIR /app

# Copy your Python runner script
COPY yt-dlp-runner.py /app/yt-dlp-runner.py

# Set the entrypoint
ENTRYPOINT ["python", "/app/yt-dlp-runner.py"]