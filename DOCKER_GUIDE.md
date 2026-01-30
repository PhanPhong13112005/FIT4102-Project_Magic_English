# Docker Setup Guide - Magic English

Hướng dẫn này giúp bạn chạy ứng dụng Magic English sử dụng Docker Compose.

## Yêu cầu

- Docker Desktop (v20.10+)
- Docker Compose (v1.29+)
- Git

## Cài đặt Docker

### Windows

1. Download: https://www.docker.com/products/docker-desktop
2. Run installer
3. Khởi động Docker Desktop

### Mac/Linux

```bash
# macOS (Homebrew)
brew install docker docker-compose

# Linux
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

## Cấu trúc Docker

```
Magic_English/
├── Backend/
│   ├── Dockerfile          # Build image cho Backend
│   └── .dockerignore
├── fontend/
│   ├── Dockerfile          # Build image cho Frontend
│   ├── nginx.conf          # Nginx configuration
│   └── .dockerignore
├── docker-compose.yml      # Production compose
└── docker-compose.dev.yml  # Development compose
```

## Chạy Ứng dụng

### Mode Production (All-in-one)

```bash
# Clone repo
git clone <repo-url>
cd Magic_English

# Build images
docker-compose build

# Run containers
docker-compose up -d
```

**Truy cập ứng dụng:**

- Frontend Web: http://localhost
- Backend API: http://localhost:5000/swagger/index.html
- Ollama: http://localhost:11434

### Mode Development (Chỉ Ollama)

Nếu bạn muốn code backend/frontend locally nhưng sử dụng Ollama trong Docker:

```bash
# Start only Ollama
docker-compose -f docker-compose.dev.yml up -d

# Backend configuration
# Cập nhật appsettings.json:
# "Ollama": {
#   "Url": "http://localhost:11434",
#   ...
# }

# Chạy Backend locally
cd Backend
dotnet run

# Chạy Frontend locally
cd fontend
flutter run
```

## Các Lệnh Hữu Ích

### Kiểm tra Trạng thái

```bash
# Xem tất cả containers
docker-compose ps

# Xem logs
docker-compose logs -f

# Xem logs của service cụ thể
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f ollama
```

### Quản lý Containers

```bash
# Dừng tất cả containers
docker-compose down

# Dừng và xóa volumes
docker-compose down -v

# Restart service
docker-compose restart backend

# Rebuild image (khi code thay đổi)
docker-compose build --no-cache

# Up lại sau khi build
docker-compose up -d
```

### Kiểm tra Database

```bash
# Truy cập vào backend container
docker exec -it magic-english-backend bash

# Xem database file
ls -la /app/data/

# Backup database
docker cp magic-english-backend:/app/data/magic_english.db ./backup.db
```

### Kiểm tra Ollama

```bash
# Xem models đã pull
docker exec magic-english-ollama ollama list

# Pull model (nếu chưa có)
docker exec magic-english-ollama ollama pull llama2

# Test API
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "test",
  "stream": false
}'
```

## Cấu hình Tùy chỉnh

### Thay đổi Environment Variables

Chỉnh sửa `docker-compose.yml`:

```yaml
environment:
  - ASPNETCORE_ENVIRONMENT=Production
  - Ollama__Model=mistral # Đổi sang model khác
  - Ollama__Url=http://ollama:11434
```

### Thay đổi Ports

```yaml
ports:
  - "8000:5000" # Backend trên port 8000
  - "3000:80" # Frontend trên port 3000
  - "11434:11434" # Ollama
```

### Volumes (Persistence)

Dữ liệu được lưu trong:

- `./Backend/data/magic_english.db` - SQLite database
- `ollama_data` - Ollama models và cache

## Triển khai (Deployment)

### Docker Hub (Push Images)

```bash
# Login
docker login

# Tag images
docker tag magic-english-backend:latest username/magic-english-backend:latest
docker tag magic-english-frontend:latest username/magic-english-frontend:latest

# Push
docker push username/magic-english-backend:latest
docker push username/magic-english-frontend:latest
```

### Docker Registry Tùy chỉnh

```bash
docker-compose config > docker-compose.prod.yml
# Edit docker-compose.prod.yml with custom registry URLs
docker-compose -f docker-compose.prod.yml up -d
```

## Khắc phục Sự cố

### Container không start

```bash
# Xem error logs
docker-compose logs backend

# Rebuild từ đầu
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Port đã được sử dụng

```bash
# Tìm process dùng port
lsof -i :5000

# Kill process
kill -9 <PID>

# Hoặc thay đổi port trong docker-compose.yml
```

### Database bị corrupt

```bash
# Xóa database và recreate
docker-compose down -v
docker-compose up -d
# Backend sẽ tự tạo database mới
```

### Ollama không phản hồi

```bash
# Check service
docker-compose ps ollama

# Restart
docker-compose restart ollama

# View logs
docker-compose logs ollama
```

## Health Checks

Tất cả services đều có health checks:

```bash
# Check status
docker-compose ps

# HEALTHY = Working
# UNHEALTHY = Có vấn đề
```

## Performance Tips

1. **Allocate enough resources to Docker**
   - CPU: Minimum 2 cores (4+ recommended)
   - RAM: Minimum 4GB (8GB+ recommended)

2. **Use named volumes** instead of bind mounts for better performance

3. **Enable BuildKit**

   ```bash
   export DOCKER_BUILDKIT=1
   ```

4. **Prune unused images and containers**
   ```bash
   docker system prune -a
   ```

## Monitoring

### View Resources Usage

```bash
docker stats
```

### View Network Traffic

```bash
docker network ls
docker network inspect magic-network
```

## Next Steps

- Xem [SETUP_GUIDE.md](SETUP_GUIDE.md) để hiểu thêm về ứng dụng
- Xem [README.md](README.md) cho tổng quan dự án
- Tham khảo [Docker Documentation](https://docs.docker.com)

---

**Happy Coding! 🐳**
