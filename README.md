# yt-dlp-container

A Docker-based **yt-dlp automation setup for Windows** with both **headed** and **headless** execution modes.

This project wraps `yt-dlp` inside a Docker container and uses PowerShell + batch scripts to provide:
- Reliable downloads
- Persistent configuration
- Automatic logging
- Retry handling
- Clean separation of code, config, and downloads

The goal is to keep everything **dynamic**, **reproducible**, and **portable**.


## 📁 Folder Structure


yt-dlp-container/
│
├── Dockerfile
├── yt-dlp-docker.ps1
│
├── run-yt-dlp.bat
├── run-yt-dlp-headless.bat
├── repair-docker-wsl.bat
│
├── config/
│   ├── cookies.txt              (required, NOT committed)
│   ├── playlists.txt            (required)
│   └── yt-dlp-options.txt       (required)
│
└── Downloads/
├── logs/
│   ├── container.log
│   └── docker_error.log
├── Archive/
└── (downloaded media files)


## 🔧 Requirements

- Windows 10 / Windows 11
- Docker Desktop (WSL2 backend)
- Internet connection
- Git (for cloning / contributing)



## 🚀 Quick Start

### 1️⃣ Clone the repository


git clone https://github.com/YOUR_USERNAME/yt-dlp-container.git
cd yt-dlp-container


### 2️⃣ Prepare configuration files

Inside the `config` folder, create the following files:

#### `cookies.txt`

Export browser cookies in **Netscape format** (required for private / age-restricted content).

> ⚠️ Never commit this file to GitHub.


#### `playlists.txt`

One URL per line. Example:


https://www.youtube.com/playlist?list=XXXXXXXX
https://www.youtube.com/watch?v=YYYYYYYY

Comments are allowed using `#`.


#### `yt-dlp-options.txt`

Standard yt-dlp options, one per line.

Example:


--continue
--no-overwrites
--retries infinite
--fragment-retries infinite
--merge-output-format mp4
--write-subs
--write-auto-subs
--sub-langs en.*
--convert-subs srt
--concurrent-fragments 1
--limit-rate 2M


## ▶️ Usage

### 🖥 Headed Mode (interactive)


run-yt-dlp.bat


* Shows output in terminal
* Writes full container output to:

  ```
  Downloads/logs/container.log
  ```
* Pauses on completion



### 🤖 Headless Mode (silent / scheduled)


run-yt-dlp-headless.bat


* No terminal output
* Designed for Task Scheduler / background runs
* Logs are written to:

  ```
  Downloads/logs/container.log
  ```

Docker startup errors (headless only) are logged to:


Downloads/logs/docker_error.log


## 📜 Logging Behavior

* `container.log` is **deleted at the start of every run**
* Fresh logs are written for each execution
* Prevents confusion from old errors



## 🔁 Retry Handling

* Failed URLs are automatically tracked
* Retry queue persists across runs
* Successful retries are removed automatically



## 🧹 Cleanup Behavior

* Empty `Downloads` folder is deleted if no media is downloaded
* Docker image is rebuilt automatically if missing or broken
* Temporary build markers are safely regenerated



## 🛠 Docker / WSL Repair

If Docker or WSL breaks on Windows, run **once** as Administrator:


repair-docker-wsl.bat


A system reboot is required afterward.



## ⚠️ Important Safety Notes

* **DO NOT commit `config/cookies.txt`**
* **DO NOT commit `Downloads/`**
* This repository is for automation code only, not media files

Use a `.gitignore` to protect sensitive data.



## 📄 License

MIT License (or change as needed)


## ✅ Status

This project is actively being debugged and improved.
Known issues and fixes are tracked during development.