#!/usr/bin/env python3
"""Kiểm tra href/src trong HTML: tồn tại, đúng HOA/thường, không dùng đường dẫn gốc '/'."""
import os, sys
from html.parser import HTMLParser
from urllib.parse import urlparse, unquote

ROOT = sys.argv[1] if len(sys.argv) > 1 else "site"

class P(HTMLParser):
    def __init__(self): super().__init__(); self.refs = []
    def handle_starttag(self, tag, attrs):
        for k, v in attrs:
            if k in ("href", "src") and v: self.refs.append((tag, k, v))

def exact_exists(path):
    """So khớp đúng HOA/thường (macOS không phân biệt, GitHub Pages có)."""
    parts = os.path.normpath(path).split(os.sep)
    cur = parts[0] if parts[0] else os.sep
    for p in parts[1:]:
        if p not in os.listdir(cur): return False
        cur = os.path.join(cur, p)
    return os.path.exists(path)

errors, checked = [], 0
for dp, _, files in os.walk(ROOT):
    for f in files:
        if not f.endswith(".html"): continue
        src = os.path.join(dp, f)
        p = P(); p.feed(open(src, encoding="utf-8").read())
        for tag, attr, val in p.refs:
            u = urlparse(val)
            if u.scheme or val.startswith(("#", "mailto:", "data:", "//")): continue
            checked += 1
            if val.startswith("/"):
                errors.append(f'{src}: <{tag} {attr}="{val}"> đường dẫn gốc sẽ hỏng trên /tên-repo/')
                continue
            target = os.path.join(dp, unquote(u.path)) if u.path else src
            if os.path.isdir(target): target = os.path.join(target, "index.html")
            if not exact_exists(target):
                errors.append(f'{src}: <{tag} {attr}="{val}"> không tồn tại / sai HOA-thường')
print(f"Đã kiểm tra {checked} liên kết.")
for e in errors: print("LỖI:", e)
sys.exit(1 if errors else 0)
