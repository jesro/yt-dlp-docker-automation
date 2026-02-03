FROM python:3.12-slim

# -------------------------------
# Install PowerShell and prerequisites
# -------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        gnupg \
        curl \
        lsb-release \
        unzip \
        procps \
        locales && \
    wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends powershell && \
    rm -rf /var/lib/apt/lists/*

# -------------------------------
# Install yt-dlp
# -------------------------------
RUN pip install --upgrade pip yt-dlp

# -------------------------------
# Set working directory
# -------------------------------
WORKDIR /app

# Copy the PowerShell script
COPY yt-dlp-docker.ps1 /app/

# Use PowerShell as the default shell
SHELL ["pwsh", "-Command"]

# Entry point
ENTRYPOINT ["pwsh", "/app/yt-dlp-docker.ps1"]