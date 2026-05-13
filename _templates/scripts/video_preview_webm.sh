#!/usr/bin/env bash
set -euo pipefail

URL="${1:?Usage: $0 <url> [start_time] [duration_s] [out.webm]}"
START="${2:-00:00:05}"
DUR="${3:-5}"
OUT="${4:-preview_${DUR}s.webm}"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
IN="$TMPDIR/input.%(ext)s"

to_seconds() {
  local value="$1"
  local a=0 b=0 c=0 h=0 m=0 s=0
  IFS=: read -r a b c <<< "$value"
  if [[ -n "${c:-}" ]]; then
    h="$a"; m="$b"; s="$c"
  elif [[ -n "${b:-}" ]]; then
    m="$a"; s="$b"
  else
    s="$a"
  fi
  awk -v h="$h" -v m="$m" -v s="$s" 'BEGIN { printf "%.3f", (h * 3600) + (m * 60) + s }'
}

START_SECONDS="$(to_seconds "$START")"
END_SECONDS="$(awk -v start="$START_SECONDS" -v dur="$DUR" 'BEGIN { printf "%.3f", start + dur }')"

YTDLP_BIN="${YTDLP_BIN:-}"
if [[ -z "$YTDLP_BIN" ]]; then
  if [[ -x "$HOME/.local/bin/yt-dlp" ]]; then
    YTDLP_BIN="$HOME/.local/bin/yt-dlp"
  else
    YTDLP_BIN="$(command -v yt-dlp)"
  fi
fi

YTDLP_ARGS=(
  -f "bv*[height<=720]+ba/best[height<=720]/best"
  --merge-output-format mp4
  --download-sections "*${START_SECONDS}-${END_SECONDS}"
  --force-keyframes-at-cuts
)

# Optional auth for Instagram/private/rate-limited pages:
#   YTDLP_COOKIES=/path/to/cookies.txt ./video_preview_webm.sh <url>
#   YTDLP_COOKIES_FROM_BROWSER=firefox ./video_preview_webm.sh <url>
if [[ -n "${YTDLP_COOKIES:-}" ]]; then
  YTDLP_ARGS+=(--cookies "$YTDLP_COOKIES")
fi
if [[ -n "${YTDLP_COOKIES_FROM_BROWSER:-}" ]]; then
  YTDLP_ARGS+=(--cookies-from-browser "$YTDLP_COOKIES_FROM_BROWSER")
fi

echo "[1/3] Downloading preview source with $YTDLP_BIN…"
if ! "$YTDLP_BIN" "${YTDLP_ARGS[@]}" -o "$IN" "$URL"; then
  cat >&2 <<'ERR'

Download failed.
For Instagram/YouTube/Vimeo this usually means login required, rate-limit, private/deleted content, or stale yt-dlp.
Try one of:
  yt-dlp -U
  YTDLP_COOKIES_FROM_BROWSER=firefox ./video_preview_webm.sh '<url>'
  YTDLP_COOKIES=/path/to/cookies.txt ./video_preview_webm.sh '<url>'
ERR
  exit 1
fi

REAL_IN="$(find "$TMPDIR" -maxdepth 1 -type f -name 'input.*' | head -n 1)"
if [[ -z "$REAL_IN" || ! -s "$REAL_IN" ]]; then
  echo "Download appeared to succeed, but no input file was created in $TMPDIR" >&2
  exit 1
fi

echo "[2/3] Encoding WebM preview…"
ffmpeg -hide_banner -loglevel error -y \
  -t "$DUR" -i "$REAL_IN" \
  -vf "scale=480:-2,fps=12" \
  -c:v libvpx-vp9 -b:v 500k -maxrate 500k -bufsize 1000k \
  -an \
  "$OUT"

echo "[3/3] Done: $OUT"
ls -lh "$OUT"
