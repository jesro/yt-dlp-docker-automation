FROM python:3.12-slim

# Install yt-dlp
RUN pip install --upgrade pip yt-dlp

WORKDIR /app

COPY yt-dlp-runner.py /app/yt-dlp-runner.py

ENTRYPOINT ["python", "/app/yt-dlp-runner.py"]