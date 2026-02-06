.PHONY: help up down build logs ps clean dev-backend dev-frontend db-shell redis-cli minio-console

# 默认目标：显示帮助信息
help:
	@echo "外汇交易系统 - 开发命令手册"
	@echo "=============================="
	@echo "make up           - 启动所有开发服务 (postgres, redis, minio)"
	@echo "make down         - 停止并移除所有服务容器"
	@echo "make build        - 重新构建服务镜像"
	@echo "make logs         - 查看所有服务的日志"
	@echo "make ps           - 查看服务状态"
	@echo "make clean        - 停止服务并清理所有数据卷 (谨慎使用！)"
	@echo "make test         - 运行测试"
	@echo ""
	@echo "数据库工具："
	@echo "make db-shell     - 进入PostgreSQL交互终端"
	@echo "make db-backup    - 备份数据库至 ./backups/"
	@echo "make redis-cli    - 进入Redis交互终端"
	@echo "make minio-console - 打开MinIO管理控制台 (浏览器自动打开)"
	@echo ""
	@echo "开发快捷命令："
	@echo "make dev-backend  - 在后端目录启动Django开发服务器 (需先进入venv)"
	@echo "make dev-frontend - 在前端目录启动Vue开发服务器"

# Docker Compose 命令
up:
	docker-compose up -d

down:
	docker-compose down

build:
	docker-compose build --no-cache

logs:
	docker-compose logs -f --tail=50

ps:
	docker-compose ps

# 数据清理（开发环境重置用）
clean:
	docker-compose down -v
	@echo "所有数据卷已被删除。下次启动将是全新的环境。"

# 数据库工具
db-shell:
	docker-compose exec postgres psql -U postgres -d fx_trading_dev

db-backup:
	mkdir -p ./backups
	@echo "正在备份数据库..."
	@docker-compose exec -T postgres pg_dump -U postgres fx_trading_dev > ./backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "备份完成！文件保存在 ./backups/"

redis-cli:
	docker-compose exec redis redis-cli

# MinIO 控制台 (在Linux上尝试用xdg-open打开浏览器)
minio-console:
	@echo "MinIO控制台地址: http://localhost:9001"
	@echo "用户名: minioadmin"
	@echo "密码: minioadmin123"
	@which xdg-open > /dev/null 2>&1 && xdg-open http://localhost:9001 || echo "请手动打开浏览器访问以上地址。"

# 本地开发快捷命令 (假设你已经在本机安装了Python和Node.js环境)
dev-backend:
	@if [ -d "./backend" ]; then \
		cd backend && . venv/bin/activate && python manage.py runserver; \
	else \
		echo "错误：后端目录 './backend' 不存在。请先完成第二阶段任务。"; \
	fi

dev-frontend:
	@if [ -d "./frontend" ]; then \
		cd frontend && npm run dev; \
	else \
		echo "错误：前端目录 './frontend' 不存在。请先完成第七阶段任务。"; \
	fi

# 测试服务连接
test:
	@echo "$(GREEN)测试服务连接...$(RESET)"
	@echo "$(YELLOW)1. 测试PostgreSQL连接...$(RESET)"
	@docker-compose exec postgres pg_isready -U fx_user -d fx_trading_dev && \
		echo "$(GREEN)PostgreSQL连接正常$(RESET)" || \
		echo "$(RED)PostgreSQL连接失败$(RESET)"
	@echo ""
	@echo "$(YELLOW)2. 测试Redis连接...$(RESET)"
	@docker-compose exec redis redis-cli ping | grep -q PONG && \
		echo "$(GREEN)Redis连接正常$(RESET)" || \
		echo "$(RED)Redis连接失败$(RESET)"
	@echo ""
	@echo "$(YELLOW)3. 测试MinIO连接...$(RESET)"
	@curl -s http://localhost:9000/minio/health/live > /dev/null && \
		echo "$(GREEN)MinIO连接正常$(RESET)" || \
		echo "$(RED)MinIO连接失败$(RESET)"