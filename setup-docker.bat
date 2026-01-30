@echo off
setlocal enabledelayedexpansion

REM Magic English Docker Setup Script (Windows)

echo ================================
echo Magic English Docker Setup
echo ================================
echo.

REM Check Docker installation
echo Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo Docker is not installed!
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo ^✓ Docker found
echo.

REM Check Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo Docker Compose is not installed!
    pause
    exit /b 1
)
echo ^✓ Docker Compose found
echo.

REM Create data directory
echo Creating data directories...
if not exist "Backend\data" mkdir Backend\data
echo ^✓ Data directories created
echo.

REM Menu
echo Select deployment mode:
echo 1) Production (All services)
echo 2) Development (Only Ollama)
set /p DEPLOY_MODE="Enter choice (1 or 2): "

echo.
echo Building Docker images...
docker-compose build --no-cache

echo.
if "%DEPLOY_MODE%"=="1" (
    echo Starting production services...
    docker-compose up -d
    echo.
    echo ^✓ All services started!
    echo.
    echo Service URLs:
    echo   Frontend:    http://localhost
    echo   Backend API: http://localhost:5000/swagger/index.html
    echo   Ollama:      http://localhost:11434
) else if "%DEPLOY_MODE%"=="2" (
    echo Starting development services (Ollama only)...
    docker-compose -f docker-compose.dev.yml up -d
    echo.
    echo ^✓ Development mode started!
    echo.
    echo Next steps:
    echo 1. Run Backend locally:
    echo    cd Backend
    echo    dotnet run
    echo.
    echo 2. Run Frontend locally (in another terminal):
    echo    cd fontend
    echo    flutter run
) else (
    echo Invalid choice!
    pause
    exit /b 1
)

echo.
echo Waiting for services to start...
timeout /t 5

echo.
echo Checking service health...
docker-compose ps

echo.
echo Useful commands:
echo   View logs:           docker-compose logs -f
echo   View backend logs:   docker-compose logs -f backend
echo   Pull AI models:      docker exec magic-english-ollama ollama pull llama2
echo   Stop services:       docker-compose down
echo   Remove everything:   docker-compose down -v
echo.
echo Setup complete! Happy learning with Magic English!
pause
