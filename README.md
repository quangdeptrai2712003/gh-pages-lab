# GitHub Pages Lab

Mục tiêu: triển khai website tĩnh lên GitHub Pages, kiểm chứng, xử lý lỗi đường dẫn/tài nguyên, lưu minh chứng truy cập.

```
site/        ← nội dung được deploy (có .nojekyll, 404.html)
scripts/     ← check_links.py · serve_local.sh · verify_live.sh
.github/workflows/pages.yml  ← CI deploy bằng GitHub Actions
evidence/    ← minh chứng (mỗi lần chạy 1 thư mục theo thời gian)
docs/REPORT_TEMPLATE.md      ← mẫu báo cáo
```

## Bước 1 – Kiểm tra cục bộ (giả lập project site)
```bash
cd ~/Documents/gh-pages-lab
python3 scripts/check_links.py site        # phải 0 lỗi
./scripts/serve_local.sh gh-pages-lab      # mở http://localhost:8000/gh-pages-lab/
```

## Bước 2 – Tạo repo & push
Cách A (có `gh` CLI):
```bash
git init -b main && git add . && git commit -m "Initial site"
gh repo create gh-pages-lab --public --source=. --push
```
Cách B: tạo repo trống trên github.com rồi
```bash
git init -b main && git add . && git commit -m "Initial site"
git remote add origin https://github.com/<user>/gh-pages-lab.git
git push -u origin main
```

## Bước 3 – Bật Pages
Repo → Settings → Pages → **Build and deployment → Source: GitHub Actions**.
Vào tab Actions, đợi workflow xanh. URL: `https://<user>.github.io/gh-pages-lab/`
(Nếu workflow chạy lần đầu bị lỗi do chưa bật Pages, bật xong rồi bấm *Re-run*.)

## Bước 4 – Kiểm chứng & lưu minh chứng
```bash
./scripts/verify_live.sh https://<user>.github.io/gh-pages-lab/
git add evidence && git commit -m "Evidence: live check" && git push
```
Kết quả ở `evidence/<timestamp>/`: access.csv, headers.txt, 404-body.html, index-snapshot.html, screenshot.png, summary.txt.

## Bước 5 – Bài tập "phá rồi sửa"
Mỗi lỗi: tạo → chạy `check_links.py` / `verify_live.sh` thấy FAIL → sửa → PASS → lưu minh chứng trước/sau.

| Lỗi cố ý | Triệu chứng | Cách sửa |
|---|---|---|
| `href="/assets/css/style.css"` | Mất CSS trên `/repo/` (404 tài nguyên) | Dùng `assets/css/style.css` (tương đối) |
| Đổi `logo.svg` → `Logo.svg` rồi commit | Chạy được trên Mac, **404 trên Pages** (phân biệt HOA/thường) | Sửa đúng tên; dùng `git mv` khi chỉ đổi hoa/thường |
| Xóa `.nojekyll`, thêm thư mục `_private/` | Thư mục bắt đầu bằng `_` bị Jekyll bỏ qua | Khôi phục `.nojekyll` |
| `src="assets/js/mian.js"` (sai tên) | JS không chạy, Console báo 404 | Sửa tên file |
| Xóa `404.html` | Hiện trang lỗi mặc định của GitHub | Khôi phục |
| Nhúng tài nguyên `http://` | Mixed content bị trình duyệt chặn | Dùng `https://` hoặc đường dẫn tương đối |
| Vừa push vẫn thấy bản cũ | Cache CDN/trình duyệt | Đợi workflow xong, Cmd+Shift+R |

## Tiêu chí hoàn thành
- [ ] Workflow Actions thành công, site truy cập được
- [ ] `verify_live.sh` PASS: mọi tài nguyên 200, URL sai trả 404
- [ ] Ít nhất 3 lỗi trong bảng trên được tái hiện + sửa + có minh chứng trước/sau
- [ ] Điền đủ `docs/REPORT_TEMPLATE.md`
