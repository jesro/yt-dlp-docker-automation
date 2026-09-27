# creates your yt-dlp-auto image containing things like:  Python 3.12, ffmpeg, yt-dlp, yt-dlp-runner.py, yt-dlp-options.txt
# Use official slim Python image
FROM python:3.12-slim    

# Install system dependencies and ffmpeg
# --no-install-recommends     
#     Install ffmpeg and its required dependencies, but don't automatically install packages that Debian marks as Recommended rather than strictly required.
# Those recommended packages can still be related to ffmpeg or useful alongside it. They aren't necessarily "unrelated to ffmpeg."
# This keep your image smaller and avoids unnecessary packages
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install yt-dlp
# --no-cache-dir     
#    Don't keep downloaded pip package caches inside the Docker image. It helps reduce image size.
RUN pip install --upgrade pip yt-dlp

# Set working directory
WORKDIR /app

# Copy runner script and yt-dlp options
COPY yt-dlp-runner.py /app/yt-dlp-runner.py

# Run the yt-dlp runner
ENTRYPOINT ["python", "/app/yt-dlp-runner.py"]
