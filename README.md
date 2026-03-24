# ✨ Magic English - AI Learning Mentor

**Magic English** là một hệ thống hỗ trợ học tiếng Anh toàn diện, ứng dụng Trí tuệ nhân tạo (**Gemini AI**) để giúp người học xây dựng lộ trình cá nhân hóa và duy trì thói quen học tập bền vững thông qua cơ chế Gamification.

---

## 🚀 Tính năng cốt lõi

### 1. Magic Vocab (Hành trình từ vựng) 📚
*   **AI Extraction:** Tự động trích xuất định nghĩa, phiên âm IPA, loại từ và câu ví dụ chỉ từ một từ khóa đầu vào.
*   **Smart Notebook:** Lưu trữ và quản lý sổ tay từ vựng cá nhân, phân loại theo cấp độ CEFR (A1-C2).

### 2. Writing Checker (Trợ lý viết bài) ✍️
*   **Phân tích thông minh:** Sử dụng Gemini AI để kiểm tra lỗi ngữ pháp, chính tả và phong cách hành văn.
*   **Phản hồi chi tiết:** Chấm điểm trên thang 100 và đưa ra các đề xuất sửa đổi cụ thể cho từng loại lỗi.

### 3. Stats & Streaks (Động lực học tập) 📊
*   **Streak Tracking:** Theo dõi chuỗi ngày học liên tục (Current Streak) và kỷ lục cá nhân (Longest Streak).
*   **Achievement System:** Hệ thống huy hiệu thực tế dựa trên dữ liệu thật từ Database giúp thúc đẩy tinh thần học tập.

---

## 🛠️ Công nghệ sử dụng

*   **Frontend:** Flutter (Quản lý trạng thái với Provider).
*   **Backend:** ASP.NET Core 8.0 (Web API).
*   **Database:** PostgreSQL (Hệ quản trị cơ sở dữ liệu mạnh mẽ).
*   **AI Engine:** Google Gemini AI (Thay thế cho các mô hình chạy local để tối ưu hiệu suất).
*   **Infrastructure:** Docker, Docker Compose, Nginx.

---

## 📦 Triển khai nhanh với Docker 🐳

Dự án đã được cấu hình sẵn để triển khai nhanh chóng trên VPS hoặc máy cục bộ.

```bash
# Clone dự án từ repository
git clone [https://github.com/your-username/Magic_English.git](https://github.com/your-username/Magic_English.git)

# Khởi chạy toàn bộ dịch vụ (Database, Backend, Frontend Web)
docker compose up -d --build

Lưu ý: Sau khi khởi chạy, hệ thống sẽ tự động tạo Schema trong PostgreSQL.

⚙️ Cấu hình hệ thống (Configuration)
Cập nhật các thông số quan trọng trong file Backend/appsettings.json trước khi chạy:

{
  "ConnectionStrings": {
    "DefaultConnection": "Host=magic-postgres-vps;Database=MagicEnglishDB;Username=postgres;Password=your_password;"
  },
  "JwtSettings": {
    "SecretKey": "PhanPhong_MagicEnglish_SecretKey_2026_Strong_Security",
    "Issuer": "MagicEnglish",
    "Audience": "MagicEnglishUsers"
  },
  "GeminiApiKey": "AIzaSyD_DÁN_API_KEY_MỚI_VÀO_ĐÂY"
}

📂 Cấu trúc thư mục dự án

Magic_English/
├── Backend/                 # Mã nguồn C# ASP.NET Core
│   ├── Controllers/         # Các API Endpoints (Auth, Vocab, Stats...)
│   ├── Services/            # Logic xử lý chính và kết nối Gemini AI
│   ├── Models/              # Định nghĩa thực thể Database
│   └── Dockerfile           # Cấu hình đóng gói Backend
├── fontend/                 # Mã nguồn Flutter Mobile/Web
│   ├── lib/
│   │   ├── providers/       # State Management (Logic dữ liệu thật)
│   │   ├── screens/         # Giao diện người dùng (UI)
│   │   └── services/        # API Client kết nối với Backend
│   └── Dockerfile           # Cấu hình đóng gói Frontend
└── docker-compose.yml       # Điều phối các dịch vụ hệ thống

📝 Nhật ký bảo trì & Sửa lỗi (Troubleshooting)
Bảo mật JWT: Khóa bí mật (SecretKey) phải dài ít nhất 32 ký tự để đáp ứng thuật toán HS256.

Kết nối Database: Khi chạy trong Docker, chuỗi kết nối phải dùng tên dịch vụ magic-postgres-vps thay vì localhost.

Gemini API Key: Đảm bảo Key không bị lộ trên các nền tảng công cộng để tránh bị Google thu hồi (Leaked Key).

Phát triển bởi nhóm 11 CNTT17-08 - 2026 🚀
