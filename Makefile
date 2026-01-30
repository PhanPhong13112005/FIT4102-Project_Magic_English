.PHONY: help build up down logs clean restart pull-models health

help:
	@echo "Magic English Docker Commands"
	@echo "================================"
	@echo "make build          - Build images"
	@echo "make up             - Start all containers (production)"
	@echo "make up-dev         - Start dev containers (only Ollama)"
	@echo "make down           - Stop all containers"
	@echo "make down-clean     - Stop and remove volumes"
	@echo "make logs           - View all logs"
	@echo "make logs-backend   - View backend logs"
	@echo "make logs-frontend  - View frontend logs"
	@echo "make logs-ollama    - View Ollama logs"
	@echo "make restart        - Restart all services"
	@echo "make status         - Check services status"
	@echo "make shell-backend  - Access backend container shell"
	@echo "make shell-ollama   - Access Ollama container shell"
	@echo "make pull-models    - Pull AI models to Ollama"
	@echo "make clean          - Remove all containers and images"
	@echo "make health         - Check health status"
	@echo "make db-backup      - Backup database"
	@echo "make db-restore     - Restore database"

build:
	docker-compose build

up:
	docker-compose up -d
	@echo "✓ All services started!"
	@echo "Frontend: http://localhost"
	@echo "Backend: http://localhost:5000/swagger"
	@echo "Ollama: http://localhost:11434"

up-dev:
	docker-compose -f docker-compose.dev.yml up -d
	@echo "✓ Development mode (Ollama only)"

down:
	docker-compose down
	@echo "✓ All services stopped"

down-clean:
	docker-compose down -v
	@echo "✓ All services and volumes removed"

logs:
	docker-compose logs -f

logs-backend:
	docker-compose logs -f backend

logs-frontend:
	docker-compose logs -f frontend

logs-ollama:
	docker-compose logs -f ollama

restart:
	docker-compose restart
	@echo "✓ All services restarted"

status:
	docker-compose ps

shell-backend:
	docker exec -it magic-english-backend bash

shell-ollama:
	docker exec -it magic-english-ollama bash

pull-models:
	docker exec magic-english-ollama ollama pull llama2
	@echo "✓ Model pulled successfully"

list-models:
	docker exec magic-english-ollama ollama list

clean:
	docker-compose down -v
	docker system prune -af
	@echo "✓ All containers and images removed"

health:
	@echo "Health Status:"
	@docker-compose ps | grep -E "HEALTHY|UNHEALTHY"

db-backup:
	@mkdir -p ./backups
	docker cp magic-english-backend:/app/data/magic_english.db ./backups/magic_english_$(shell date +%Y%m%d_%H%M%S).db
	@echo "✓ Database backed up"

db-restore:
	@if [ -z "$(FILE)" ]; then echo "Usage: make db-restore FILE=./backups/magic_english.db"; exit 1; fi
	docker cp $(FILE) magic-english-backend:/app/data/magic_english.db
	docker-compose restart backend
	@echo "✓ Database restored"

rebuild: down build up
	@echo "✓ Full rebuild complete!"

test-api:
	@echo "Testing Backend API..."
	@curl -s http://localhost:5000/swagger/index.html > /dev/null && echo "✓ Backend healthy" || echo "✗ Backend not responding"

test-frontend:
	@echo "Testing Frontend..."
	@curl -s http://localhost/ > /dev/null && echo "✓ Frontend healthy" || echo "✗ Frontend not responding"

test-ollama:
	@echo "Testing Ollama..."
	@curl -s http://localhost:11434/api/tags > /dev/null && echo "✓ Ollama healthy" || echo "✗ Ollama not responding"

test-all: test-api test-frontend test-ollama
	@echo "✓ All tests complete"
