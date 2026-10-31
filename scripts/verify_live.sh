#!/usr/bin/env bash
# Dùng: ./scripts/verify_live.sh https://<user>.github.io/<repo>/
# Kiểm tra mọi file trong site/ + URL sai (phải 404), lưu minh chứng vào evidence/<timestamp>/
set -uo pipefail
cd "$(dirname "$0")/.."
BASE="${1:?Thiếu URL, ví dụ https://user.github.io/repo/}"; BASE="${BASE%/}/"
TS=$(date +%Y%m%d-%H%M%S); OUT="evidence/$TS"; mkdir -p "$OUT"
CSV="$OUT/access.csv"; fail=0
echo "timestamp,url,http_code,content_type,bytes,time_s" > "$CSV"

check() { # url expected_code
  local r code
  r=$(curl -s -o /dev/null -L -w "%{http_code},%{content_type},%{size_download},%{time_total}" "$1")
  echo "$(date -u +%FT%TZ),$1,$r" >> "$CSV"
  code=${r%%,*}
  if [ "$code" = "$2" ]; then echo "OK   $code $1"; else echo "FAIL $code (mong đợi $2) $1"; fail=1; fi
}

while IFS= read -r f; do
  rel="${f#site/}"
  [ "$rel" = ".nojekyll" ] && continue
  [ "$rel" = "404.html" ] && continue
  check "$BASE$rel" 200
done < <(find site -type f | sort)
check "$BASE" 200
check "${BASE}khong-ton-tai-$TS" 404

curl -sI "$BASE" > "$OUT/headers.txt"
curl -s "${BASE}khong-ton-tai-$TS" > "$OUT/404-body.html"
curl -s "$BASE" > "$OUT/index-snapshot.html"
{ echo "URL: $BASE"; echo "Thời điểm: $(date)"; echo "Máy: $(uname -a)"
  echo "Kết quả: $([ $fail = 0 ] && echo PASS || echo FAIL)"; } > "$OUT/summary.txt"

# Ảnh chụp màn hình (Chrome headless trên macOS, nếu có)
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ -x "$CHROME" ]; then
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1280,800 \
    --screenshot="$OUT/screenshot.png" "$BASE" >/dev/null 2>&1 && echo "Đã chụp: $OUT/screenshot.png"
fi

echo; cat "$OUT/summary.txt"; echo "Minh chứng: $OUT/"
exit $fail
