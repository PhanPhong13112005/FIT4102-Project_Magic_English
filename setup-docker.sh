#!/bin/bash

# Magic English Docker Deployment Script
# Tự động cài đặt, build, và chạy ứng dụng

set -e  # Exit on error

echo "================================"
echo "Magic English Docker Setup"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Docker installation
echo -e "${YELLOW}Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed!${NC}"
    echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo -e "${GREEN}✓ Docker found${NC}"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose found${NC}"
echo ""

# Check if Docker daemon is running
echo -e "${YELLOW}Checking Docker daemon...${NC}"
if ! docker ps &> /dev/null; then
    echo -e "${RED}Docker daemon is not running!${NC}"
    echo "Please start Docker Desktop"
    exit 1
fi
echo -e "${GREEN}✓ Docker daemon is running${NC}"
echo ""

# Create data directory
echo -e "${YELLOW}Creating data directories...${NC}"
mkdir -p ./Backend/data
echo -e "${GREEN}✓ Data directories created${NC}"
echo ""

# Ask user for deployment mode
echo -e "${YELLOW}Select deployment mode:${NC}"
echo "1) Production (All services: Backend, Frontend, Ollama)"
echo "2) Development (Only Ollama, run Backend/Frontend locally)"
read -p "Enter choice (1 or 2): " DEPLOY_MODE

echo ""
echo -e "${YELLOW}Building Docker images...${NC}"
docker-compose build --no-cache

echo ""
if [ "$DEPLOY_MODE" = "1" ]; then
    echo -e "${YELLOW}Starting production services...${NC}"
    docker-compose up -d
    
    echo ""
    echo -e "${GREEN}✓ All services started!${NC}"
    echo ""
    echo -e "${YELLOW}Service URLs:${NC}"
    echo -e "  ${GREEN}Frontend:${NC}    http://localhost"
    echo -e "  ${GREEN}Backend API:${NC}  http://localhost:5000/swagger/index.html"
    echo -e "  ${GREEN}Ollama:${NC}      http://localhost:11434"
    
elif [ "$DEPLOY_MODE" = "2" ]; then
    echo -e "${YELLOW}Starting development services (Ollama only)...${NC}"
    docker-compose -f docker-compose.dev.yml up -d
    
    echo ""
    echo -e "${GREEN}✓ Development mode started!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Run Backend locally:"
    echo "   cd Backend"
    echo "   dotnet run"
    echo ""
    echo "2. Run Frontend locally (in another terminal):"
    echo "   cd fontend"
    echo "   flutter run"
    echo ""
    echo -e "${YELLOW}Ollama will be available at:${NC}"
    echo "   http://localhost:11434"
else
    echo -e "${RED}Invalid choice!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 5

echo ""
echo -e "${YELLOW}Checking service health...${NC}"
docker-compose ps

echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View logs:           docker-compose logs -f"
echo "  View backend logs:   docker-compose logs -f backend"
echo "  Pull AI models:      docker exec magic-english-ollama ollama pull llama2"
echo "  Stop services:       docker-compose down"
echo "  Remove everything:   docker-compose down -v"
echo ""
echo -e "${GREEN}Setup complete! Happy learning with Magic English! 🚀${NC}"
