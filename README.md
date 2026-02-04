# yt-dlp-docker-automation

A Docker-based **yt-dlp automation setup for Windows** with both **headed** and **headless** execution modes.

This project wraps `yt-dlp` inside a Docker container and uses batch scripts + Python to provide:
- Reliable downloads
- Persistent configuration
- Automatic logging
- Retry handling
- Clean separation of code, config, and downloads

The goal is to keep everything **dynamic**, **reproducible**, and **portable**.

---

## 📁 Folder Structure

```

yt-dlp-docker-automation/
│
├── Dockerfile
├── run-yt-dlp.bat
├── run-yt-dlp-headless.bat
├── repair-docker-wsl.bat
├── yt-dlp-runner.py
├── LICENSE
├── README.md
├── .gitignore
│
├── config/
│   ├── cookies-sample.txt       # Sample, included
│   ├── cookies.txt              # Required, user-provided, NOT committed
│   ├── playlists-sample.txt     # Sample, included
│   ├── playlists.txt            # Required, user-provided
│   └── yt-dlp-options.txt       # Required, included
│
└── Downloads/
├── logs/
│   ├── container.log
│   └── docker_error.log
├── Archive/
└── (downloaded media files)

````

> The `Downloads` folder is **created automatically** on first run.

---

## 🔧 Requirements

- Windows 10 / 11  
- Docker Desktop (WSL2 backend)  
- Internet connection  

> Git is optional if cloning the repository.

---

## 🚀 Quick Start

### 1️⃣ Clone the repository

```bat
git clone https://github.com/jesro/yt-dlp-docker-automation.git
cd yt-dlp-docker-automation
````

### 2️⃣ Prepare configuration files

Inside the `config` folder, create the following files:

#### `cookies.txt`

Export your browser cookies in **Netscape format** (required for private or age-restricted content).

> ⚠️ Never commit this file to GitHub.

#### `playlists.txt`

One URL per line:

```
https://www.youtube.com/playlist?list=XXXXXXXX
https://www.youtube.com/watch?v=YYYYYYYY
```

Comments are allowed using `#`.

#### `yt-dlp-options.txt`

Updated example options compatible with the latest `yt-dlp`:

```
--continue
--no-overwrites
--retries 100
--fragment-retries 100
--file-access-retries 100
--retry-sleep 10
--sleep-interval 5
--sleep-requests 3
--concurrent-fragments 1
--limit-rate 2M
--merge-output-format mp4
--write-subs
--write-auto-subs
--sub-langs en.*
--convert-subs srt
--extractor-args youtube:android
-f bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[ext=mp4]
```

---

## ▶️ Usage

### 🖥 Headed Mode (interactive)

```bat
run-yt-dlp.bat
```

* Shows output in terminal
* Logs are written to `Downloads/logs/container.log`
* Pauses on completion

### 🤖 Headless Mode (silent / scheduled)

```bat
run-yt-dlp-headless.bat
```

* No terminal output
* Designed for Task Scheduler / background runs
* Logs are written to `Downloads/logs/container.log`
* Docker startup errors go to `Downloads/logs/docker_error.log`

---

## 📜 Logging Behavior

* `container.log` is **cleared at the start** of each run
* Fresh logs are written for every execution
* Failed downloads are recorded and retried automatically

> If downloads fail, **only `container.log`** is required for debugging.

---

## 🔁 Retry Handling

* Failed URLs persist across runs
* Successful retries are removed automatically
* Configurable via `yt-dlp-options.txt`

---

## 🧹 Cleanup Behavior

* Empty `Downloads` folder is removed if no media is downloaded
* Docker image rebuilds automatically if missing or corrupted
* Temporary build markers are safely regenerated

---

## 🛠 Docker / WSL Repair

If Docker or WSL breaks on Windows, run as Administrator:

```bat
repair-docker-wsl.bat
```

> ⚠️ Reboot required afterward.

---

## ⚠️ Important Notes

* **Do NOT commit `config/cookies.txt`**
* **Do NOT commit `Downloads/`**
* Only automation code is included in the repo

Use `.gitignore` to protect sensitive files.

---

## 💡 Tips & Troubleshooting

1. **Download fails / videos not downloading**

   * Check `Downloads/logs/container.log` for detailed yt-dlp errors.
   * Verify that URLs in `playlists.txt` are valid.
   * Make sure `cookies.txt` is correctly exported for private content.

2. **Docker errors (headless only)**

   * Check `Downloads/logs/docker_error.log`.
   * Run `repair-docker-wsl.bat` as Administrator and reboot if needed.

3. **Partial downloads or network issues**

   * Increase retries in `yt-dlp-options.txt` (`--retries 100` is recommended).
   * Reduce `--concurrent-fragments` if downloads fail frequently.

4. **Subtitles not downloading**

   * Ensure `--write-subs` and `--sub-langs en.*` are enabled.
   * Auto-generated subtitles require `--write-auto-subs`.

5. **Debugging**

   * Only `container.log` is needed to share for troubleshooting failed runs.
   * Include failed URLs if persistent errors occur.

---

## 📄 License

MIT License (or change as needed)

---

## ✅ Status

* Actively maintained
* Compatible with the latest `yt-dlp` (including `--extractor-args youtube:android`)
* Known issues tracked during development

```