#!/usr/bin/env bash
set -euo pipefail

URL="${1:?Usage: $0 <url> [start_time] [duration_s] [out.webm]}"
START="${2:-00:00:05}"
DUR="${3:-5}"
OUT="${4:-preview_${DUR}s.webm}"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
IN="$TMPDIR/input.%(ext)s"

echo "[1/3] Downloading…"
yt-dlp -f "bv*+ba/best" -o "$IN" "$URL"

REAL_IN="$(ls -1 "$TMPDIR"/input.* | head -n 1)"

echo "[2/3] Encoding WebM preview…"
ffmpeg -hide_banner -loglevel error \
  -ss "$START" -t "$DUR" -i "$REAL_IN" \
  -vf "scale=480:-2,fps=12" \
  -c:v libvpx-vp9 -b:v 500k -maxrate 500k -bufsize 1000k \
  -an \
  "$OUT"

echo "[3/3] Done: $OUT"
ls -lh "$OUT"
