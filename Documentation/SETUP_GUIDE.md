# Setup Guide - Magic English

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Visual Studio Code** (latest version)
- **.NET 8 SDK** (download from [microsoft.com](https://dotnet.microsoft.com/download/dotnet/8.0))
- **SQL Server 2019 or Higher** (or SQL Server Express)
- **Flutter SDK** (latest stable version)
- **Git** (for version control)
- **Ollama Cloud API Key** (from Ollama Cloud portal)

---

## Part 1: Backend Setup

### Step 1.1: Navigate to Backend Directory

```bash
cd Magic_English/Backend/MagicEnglishAPI
```

### Step 1.2: Restore NuGet Packages

```bash
dotnet restore
```

### Step 1.3: Configure Database Connection

Edit `appsettings.json` and update the connection string:

```json
"ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=MagicEnglishDB;User Id=sa;Password=YourPassword123!;Encrypt=false;"
}
```

**For Windows Authentication:**
```json
"DefaultConnection": "Server=(local);Database=MagicEnglishDB;Integrated Security=true;Encrypt=false;"
```

### Step 1.4: Configure Ollama API

Update `appsettings.json` with your Ollama API details:

```json
"OllamaApi": {
    "BaseUrl": "https://api.ollamcloud.com/api",
    "ApiKey": "your-api-key-here",
    "VocabularyModel": "llama2:13b",
    "GrammarModel": "llama2:13b",
    "TimeoutSeconds": 30
}
```

### Step 1.5: Create and Seed Database

**Option A: Using Entity Framework Core (Recommended)**

Entity Framework will automatically create the database and apply migrations when you first run the application.

**Option B: Using SQL Scripts**

1. Open SQL Server Management Studio
2. Create a new database: `MagicEnglishDB`
3. Run the script: `Database/schema.sql`
4. Run seed data: `Database/seed_data.sql`

### Step 1.6: Build the Project

```bash
dotnet build
```

### Step 1.7: Run the API Server

```bash
dotnet run
```

The API will start on `http://localhost:5000`

**Verify it's running:**
- Visit: `http://localhost:5000/swagger` (Swagger UI)
- You should see all API endpoints

### Step 1.8: Test API Endpoints

Test creating a user:

```bash
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

---

## Part 2: Database Setup (SQL Server)

### Step 2.1: Launch SQL Server

Start SQL Server instance (local or remote)

### Step 2.2: Create Database

**Using SQL Server Management Studio:**
1. Right-click "Databases" → New Database
2. Enter name: `MagicEnglishDB`
3. Click OK

**Using Command Line (sqlcmd):**
```sql
sqlcmd -S localhost -U sa -P YourPassword123!
CREATE DATABASE MagicEnglishDB;
GO
USE MagicEnglishDB;
GO
```

### Step 2.3: Run Schema Script

Execute `Database/schema.sql` in SQL Server:

```bash
sqlcmd -S localhost -U sa -P YourPassword123! -i Database\schema.sql
```

### Step 2.4: Insert Seed Data (Optional)

Execute `Database/seed_data.sql`:

```bash
sqlcmd -S localhost -U sa -P YourPassword123! -i Database\seed_data.sql
```

### Step 2.5: Verify Database

Check if tables were created:

```sql
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo';
```

---

## Part 3: Mobile (Flutter) Setup

### Step 3.1: Navigate to Mobile Directory

```bash
cd Magic_English/Mobile/magic_english
```

### Step 3.2: Get Flutter Dependencies

```bash
flutter pub get
```

### Step 3.3: Configure API Endpoint

Edit `lib/services/api_client.dart` and update the base URL:

```dart
static const String baseUrl = 'http://localhost:5000/api/v1';
// For Android emulator: http://10.0.2.2:5000/api/v1
// For iOS simulator: http://localhost:5000/api/v1
// For physical device: http://YOUR_MACHINE_IP:5000/api/v1
```

### Step 3.4: Run Flutter App

**On Android Emulator:**
```bash
flutter run -d emulator-5554
```

**On iOS Simulator:**
```bash
flutter run -d booted
```

**On Physical Device:**
```bash
flutter run
```

---

## Troubleshooting

### Issue: "Cannot connect to database"

**Solution:**
- Check SQL Server is running
- Verify connection string in `appsettings.json`
- Ensure firewall allows port 1433 (SQL Server)
- Try: `sqlcmd -S localhost -U sa`

---

### Issue: "Ollama API Key Invalid"

**Solution:**
- Verify API key in `appsettings.json`
- Check API key has not expired
- Visit Ollama Cloud portal to regenerate key

---

### Issue: "Flutter can't reach backend API"

**Solution:**
- Verify Backend is running: `http://localhost:5000/swagger`
- Check API endpoint in `lib/services/api_client.dart`
- For emulator, use: `http://10.0.2.2:5000/api/v1`
- Check firewall/network connectivity

---

### Issue: "Entity Framework migration errors"

**Solution:**
- Delete existing database
- Run: `dotnet ef database drop --force`
- Run: `dotnet run` (EF will recreate)

---

## Development Workflow

### Visual Studio Code Setup

**Recommended Extensions:**
- C# Dev Kit
- Entity Framework Core Power Tools
- REST Client
- Dart
- Flutter

### Debugging

**Backend (.NET):**
```bash
dotnet run --no-build
```

**Mobile (Flutter):**
```bash
flutter run --debug
```

### Run Tests

```bash
# Unit tests
dotnet test

# Flutter tests
flutter test
```

---

## Production Deployment

### Backend Deployment

1. **Build Release Version:**
```bash
dotnet publish -c Release -o ./publish
```

2. **Deploy to Server:**
   - Azure App Service
   - AWS EC2
   - Docker Container

3. **Configure Production appsettings.json**

### Mobile Deployment

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## Environment Variables

### Development
- Store in `appsettings.Development.json`
- Includes debug logging

### Production
- Use environmental variables or secrets management
- Never commit production API keys
- Use Azure Key Vault or similar

Example:
```json
{
  "OllamaApi:ApiKey": "from-environment"
}
```

---

## CI/CD Setup

### GitHub Actions Example

```yaml
name: Build and Test
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '8.0.x'
      - run: dotnet build
      - run: dotnet test
```

---

## Monitoring

### Logging

Check logs in:
- `logs/` directory (file logs)
- Console output (development)
- Application Insights (production)

### Performance

- Monitor API response times
- Track database query performance
- Monitor Ollama API latency

---

## Common Commands

### Backend
```bash
# Restore packages
dotnet restore

# Build
dotnet build

# Run
dotnet run

# Run tests
dotnet test

# Create migration (if needed)
dotnet ef migrations add MigrationName
dotnet ef database update
```

### Mobile
```bash
# Get dependencies
flutter pub get

# Build
flutter build apk

# Run
flutter run

# Run tests
flutter test

# Clean
flutter clean
```

### Database
```bash
# Connect to SQL Server
sqlcmd -S localhost -U sa -P YourPassword123!

# Run script
sqlcmd -S localhost -i script.sql
```

---

## Next Steps

1. Create users through API
2. Test vocabulary endpoints
3. Test grammar checking endpoints
4. Configure Flutter app with real data
5. Test UI with actual API calls

---

**Setup Guide Version:** 1.0  
**Last Updated:** March 11, 2024
