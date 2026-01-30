# Magic English - Complete Guide

Magic English là một ứng dụng all-in-one giúp người tự học tiếng Anh xây dựng thói quen học tập đều đặn thông qua ba module chính:

1. **Magic Vocab** - Quản lý từ vựng thông minh
2. **Grammar & Style Checker** - Chấm điểm và sửa lỗi viết
3. **Stats & Streaks** - Theo dõi tiến độ và thành tích

## Cách nhanh nhất: Docker 🐳

Nếu bạn có Docker, chỉ cần một lệnh:

```bash
# Windows
setup-docker.bat

# Mac/Linux
bash setup-docker.sh

# Hoặc trực tiếp
docker-compose up -d
```

**Frontend:** http://localhost  
**Backend API:** http://localhost:5000/swagger  
**Ollama:** http://localhost:11434

👉 Xem [DOCKER_GUIDE.md](DOCKER_GUIDE.md) để hướng dẫn chi tiết.

## Kiến trúc Ứng dụng

```
Magic_English/
├── Backend/                    # C# ASP.NET Core API
│   ├── Controllers/           # API endpoints
│   ├── Models/               # Database models
│   ├── Services/             # Business logic
│   ├── Data/                 # Database context
│   ├── DTOs/                 # Data transfer objects
│   ├── appsettings.json      # Configuration
│   ├── Dockerfile            # Docker image
│   └── Program.cs            # Startup configuration
│
├── fontend/                    # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart         # Entry point
│   │   ├── screens/          # UI screens
│   │   ├── providers/        # State management
│   │   ├── models/           # Data models
│   │   └── services/         # API client
│   ├── Dockerfile            # Docker image
│   ├── nginx.conf            # Web server config
│   └── pubspec.yaml          # Dependencies
│
├── docker-compose.yml         # Production setup
├── docker-compose.dev.yml     # Development setup
├── Makefile                   # Docker commands
└── setup-docker.sh            # Auto setup script
```

## Thiết lập Backend (C#)

### Yêu cầu

- .NET 8.0 SDK
- Visual Studio Code hoặc Visual Studio

### Cài đặt

```bash
cd Backend
dotnet restore
dotnet build
```

### Cấu hình Ollama API

Chỉnh sửa file `appsettings.json`:

```json
{
  "Ollama": {
    "Url": "http://localhost:11434",
    "Model": "llama2"
  },
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=magic_english.db"
  }
}
```

### Chạy Backend

```bash
dotnet run
```

Backend sẽ chạy tại `http://localhost:5000`

## Thiết lập Frontend (Flutter)

### Yêu cầu

- Flutter SDK 3.10+
- Android Studio hoặc Xcode (tùy theo nền tảng)

### Cài đặt Dependencies

```bash
cd fontend
flutter pub get
```

### Chỉnh sửa API URL

Nếu backend chạy trên máy khác, cập nhật `lib/services/api_client.dart`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:5000/api';
```

### Chạy ứng dụng

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## Tính năng Chi tiết

### 1. Magic Vocab 📚

- **Thêm từ mới**: Nhập từ tiếng Anh, hệ thống tự động lấy:
  - Định nghĩa tiếng Việt
  - Phiên âm IPA
  - Loại từ (noun, verb, adj...)
  - Câu ví dụ
  - Cấp độ CEFR (A1-C2)
- **Xem sổ tay**: Danh sách tất cả từ vựng đã học
- **Tìm kiếm**: Nhanh chóng tìm từ hoặc định nghĩa

### 2. Grammar & Style Checker ✍️

- **Nhập văn bản**: Gõ hoặc dán câu/đoạn văn
- **Nhận phản hồi ngay lập tức**:
  - Điểm số (0-10)
  - Danh sách lỗi (grammar, spelling, style)
  - Đề xuất cải thiện chi tiết
- **Lưu lịch sử**: Xem tất cả các bài kiểm tra trước

### 3. Stats & Streaks 📊

- **Chuỗi ngày học** (Streak):
  - Current Streak: Số ngày liên tục học
  - Longest Streak: Kỷ lục cá nhân
- **Thống kê Tổng quát**:
  - Tổng số từ vựng đã học
  - Các thành tích (3-day, 7-day, 30-day streak)
  - Số lượt viết kiểm tra
- **Biểu đồ Trực quan**:
  - Pie chart: Phân bổ loại từ
  - Bar chart: Phân bổ theo cấp độ CEFR

## API Endpoints

### Vocabulary

- `POST /api/vocabulary/add` - Thêm từ mới
- `GET /api/vocabulary/list?page=1&pageSize=20` - Danh sách từ
- `GET /api/vocabulary/{id}` - Chi tiết từ
- `GET /api/vocabulary/search?term=hello` - Tìm kiếm

### Writing

- `POST /api/writing/check` - Kiểm tra văn bản
- `GET /api/writing/submissions` - Lịch sử kiểm tra

### Stats

- `GET /api/stats/stats` - Thống kê cá nhân
- `GET /api/stats/dashboard` - Dashboard đầy đủ
- `POST /api/stats/update-streak` - Cập nhật chuỗi

## Tích hợp Ollama

Magic English sử dụng Ollama Cloud API cho:

1. **Vocabulary Extraction**: Lấy thông tin từ vựng
2. **Writing Analysis**: Phân tích và chữa bài viết

### Cài đặt Ollama Local

```bash
# Download Ollama từ https://ollama.ai

# Pull model
ollama pull llama2

# Run server
ollama serve
```

## Cấu trúc Database

SQLite với các bảng:

- **Vocabularies**: Lưu từ vựng
- **WritingSubmissions**: Lưu bài kiểm tra viết
- **UserStats**: Thống kê người dùng
- **DailyActivities**: Theo dõi hoạt động hàng ngày

## Khắc phục Sự cố

### Backend không kết nối

- Kiểm tra port 5000 có đang chạy: `netstat -an | grep 5000`
- Kiểm tra CORS được bật trong `Program.cs`

### Ollama không phản hồi

- Đảm bảo Ollama server đang chạy: `ollama serve`
- Kiểm tra URL trong `appsettings.json`

### Lỗi Database

- Xóa file `magic_english.db` để reset database
- Chạy lại: `dotnet run`

## Phát triển Thêm

### Thêm tính năng mới

1. Tạo Model trong Backend
2. Thêm DbSet trong `AppDbContext`
3. Tạo Service layer
4. Tạo Controller
5. Tạo DTO nếu cần
6. Cập nhật Flutter API Client
7. Tạo UI Screen trong Flutter

## Liên hệ & Hỗ trợ

Để báo cáo lỗi hoặc yêu cầu tính năng, vui lòng tạo issue hoặc liên hệ trực tiếp.

---

**Chúc bạn học tập hiệu quả với Magic English!** 🚀
