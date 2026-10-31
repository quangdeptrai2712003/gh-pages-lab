#!/usr/bin/env bash
# Giả lập project site: phục vụ site/ dưới tiền tố /<repo>/ để bắt lỗi đường dẫn TRƯỚC khi deploy.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="${1:-gh-pages-lab}"; PORT="${2:-8000}"
rm -rf /tmp/ghp-sim && mkdir -p /tmp/ghp-sim
ln -s "$PWD/site" "/tmp/ghp-sim/$REPO"
echo "Mở: http://localhost:$PORT/$REPO/   (Ctrl+C để dừng)"
cd /tmp/ghp-sim && python3 -m http.server "$PORT"
