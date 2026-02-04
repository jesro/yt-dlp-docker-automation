import subprocess
from pathlib import Path
import sys
import datetime
import shlex

BASE_DIR = Path("/downloads")
CONFIG_DIR = Path("/config")

LOG_DIR = BASE_DIR / "logs"
ARCHIVE_DIR = BASE_DIR / "Archive"

COOKIES = CONFIG_DIR / "cookies.txt"
PLAYLISTS = CONFIG_DIR / "playlists.txt"
OPTS = CONFIG_DIR / "yt-dlp-options.txt"

LOG_DIR.mkdir(parents=True, exist_ok=True)
ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)

ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
master_log = LOG_DIR / f"run_{ts}.log"


def log(msg: str):
    with master_log.open("a", encoding="utf-8") as f:
        f.write(msg + "\n")


def log_and_print(msg: str):
    print(msg, flush=True)
    log(msg)


log_and_print("==================================================")
log_and_print(f"Started   : {datetime.datetime.now()}")
log_and_print("MODE      : DOCKER")
log_and_print("==================================================")


# --------------------------------------------------
# Safety checks
# --------------------------------------------------
for f in (COOKIES, PLAYLISTS, OPTS):
    if not f.exists():
        log_and_print(f"ERROR: Missing required file {f}")
        sys.exit(1)


# --------------------------------------------------
# Load yt-dlp options (PROPERLY split arguments)
# --------------------------------------------------
common_opts = []

for line in OPTS.read_text(encoding="utf-8").splitlines():
    line = line.strip()
    if not line or line.startswith("#"):
        continue

    # Split like a real shell would
    common_opts.extend(shlex.split(line))


# Always-enforced options
common_opts += [
    "--cookies", str(COOKIES),
    "--download-archive", str(ARCHIVE_DIR / "archive.txt"),
]


# --------------------------------------------------
# Load URLs
# --------------------------------------------------
urls = [
    line.strip()
    for line in PLAYLISTS.read_text(encoding="utf-8").splitlines()
    if line.strip() and not line.strip().startswith("#")
]

if not urls:
    log_and_print("ERROR: playlists.txt contains no URLs")
    sys.exit(1)


# --------------------------------------------------
# Run downloads
# --------------------------------------------------
for url in urls:
    log_and_print(f"\nDownloading: {url}")

    cmd = [
        "yt-dlp",
        *common_opts,
        "-o",
        "/downloads/%(uploader)s/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s",
        url,
    ]

    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    for line in proc.stdout:
        log_and_print(line.rstrip())

    proc.wait()

    if proc.returncode != 0:
        log_and_print(f"FAILED: {url}")


log_and_print("\nFinished  : " + str(datetime.datetime.now()))
log_and_print("==================================================")