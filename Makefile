# 颜色定义
GREEN=\033[0;32m
RED=\033[0;31m
YELLOW=\033[1;33m
BLUE=\033[0;34m
CYAN=\033[0;36m
MAGENTA=\033[0;35m
RESET=\033[0m

.PHONY: help up down build logs ps clean dev-backend dev-frontend db-shell redis-cli minio-console test init

# 默认目标：显示帮助信息
help:
	@echo -e "$(CYAN)外汇交易系统 - 开发命令手册$(RESET)"
	@echo -e "$(CYAN)==============================$(RESET)"
	@echo -e "$(GREEN)基础命令:$(RESET)"
	@echo -e "  make up           - 启动所有开发服务 (postgres, redis, minio)"
	@echo -e "  make down         - 停止并移除所有服务容器"
	@echo -e "  make build        - 重新构建服务镜像"
	@echo -e "  make logs         - 查看所有服务的日志"
	@echo -e "  make ps           - 查看服务状态"
	@echo -e "  make clean        - 停止服务并清理所有数据卷 $(RED)(谨慎使用！)$(RESET)"
	@echo -e "  make test         - 运行服务连接测试"
	@echo -e "  make init         - 项目初始化设置"
	@echo ""
	@echo -e "$(GREEN)数据库工具:$(RESET)"
	@echo -e "  make db-shell     - 进入PostgreSQL交互终端"
	@echo -e "  make db-backup    - 备份数据库至 ./backups/"
	@echo -e "  make redis-cli    - 进入Redis交互终端"
	@echo -e "  make minio-console - 打开MinIO管理控制台 (浏览器自动打开)"
	@echo ""
	@echo -e "$(GREEN)开发快捷命令:$(RESET)"
	@echo -e "  make dev-backend  - 在后端目录启动Django开发服务器 (需先进入venv)"
	@echo -e "  make dev-frontend - 在前端目录启动Vue开发服务器"

# Docker Compose 命令
up:
	@echo -e "$(CYAN)启动所有开发服务...$(RESET)"
	docker-compose up -d
	@echo -e "$(GREEN)✅ 服务启动完成！$(RESET)"
	@echo -e "$(YELLOW)使用 'make logs' 查看日志，'make ps' 查看状态$(RESET)"

down:
	@echo -e "$(YELLOW)停止并移除所有服务容器...$(RESET)"
	docker-compose down
	@echo -e "$(GREEN)✅ 服务已停止$(RESET)"

build:
	@echo -e "$(CYAN)重新构建服务镜像...$(RESET)"
	docker-compose build --no-cache
	@echo -e "$(GREEN)✅ 镜像构建完成$(RESET)"

logs:
	@echo -e "$(CYAN)查看服务日志 (最新50行，Ctrl+C退出)...$(RESET)"
	docker-compose logs -f --tail=50

ps:
	@echo -e "$(CYAN)服务状态:$(RESET)"
	docker-compose ps

# 数据清理（开发环境重置用）
clean:
	@echo -e "$(RED)警告：这将删除所有数据卷，包括数据库数据！$(RESET)"
	@read -p "确定要继续吗？(yes/no): " confirm; \
	if [ "$$confirm" = "yes" ] || [ "$$confirm" = "y" ]; then \
		echo -e "$(YELLOW)停止服务并清理所有数据卷...$(RESET)"; \
		docker-compose down -v; \
		echo -e "$(GREEN)✅ 所有数据卷已被删除。下次启动将是全新的环境。$(RESET)"; \
	else \
		echo -e "$(YELLOW)操作已取消。$(RESET)"; \
	fi

# 项目初始化设置
init:
	@echo -e "$(CYAN)项目初始化设置...$(RESET)"
	@if [ ! -f ".env" ]; then \
		echo -e "$(YELLOW)创建 .env 文件...$(RESET)"; \
		cp .env.example .env; \
		echo -e "$(GREEN)✅ .env 文件已创建，请编辑配置$(RESET)"; \
	else \
		echo -e "$(YELLOW)⚠️  .env 文件已存在，跳过创建$(RESET)"; \
	fi
	@echo -e "$(YELLOW)创建必要的目录...$(RESET)"
	mkdir -p logs backups uploads
	@echo -e "$(GREEN)✅ 项目初始化完成$(RESET)"
	@echo -e "$(YELLOW)下一步: 1. 编辑 .env 文件配置 2. 运行 'make up' 启动服务$(RESET)"

# 数据库工具
db-shell:
	@echo -e "$(CYAN)进入 PostgreSQL 交互终端...$(RESET)"
	@echo -e "$(YELLOW)数据库: fx_trading_dev, 用户: fx_user$(RESET)"
	@echo -e "$(YELLOW)退出: 输入 \\q 或按 Ctrl+D$(RESET)"
	docker-compose exec postgres psql -U fx_user -d fx_trading_dev

db-backup:
	@echo -e "$(CYAN)备份数据库...$(RESET)"
	mkdir -p ./backups
	@echo -e "$(YELLOW)正在备份数据库 fx_trading_dev...$(RESET)"
	@docker-compose exec -T postgres pg_dump -U fx_user fx_trading_dev > ./backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo -e "$(GREEN)✅ 备份完成！文件保存在 ./backups/$(RESET)"
	@ls -la ./backups/*.sql 2>/dev/null | tail -5

redis-cli:
	@echo -e "$(CYAN)进入 Redis 交互终端...$(RESET)"
	@echo -e "$(YELLOW)退出: 输入 quit 或按 Ctrl+D$(RESET)"
	docker-compose exec redis redis-cli

# MinIO 控制台 (在Linux上尝试用xdg-open打开浏览器)
minio-console:
	@echo -e "$(CYAN)MinIO 对象存储控制台$(RESET)"
	@echo -e "$(GREEN)控制台地址: http://localhost:9001$(RESET)"
	@echo -e "$(YELLOW)用户名: minioadmin$(RESET)"
	@echo -e "$(YELLOW)密码: minioadmin123$(RESET)"
	@echo -e "$(CYAN)API地址: http://localhost:9000$(RESET)"
	@which xdg-open > /dev/null 2>&1 && xdg-open http://localhost:9001 || echo -e "$(YELLOW)请手动打开浏览器访问以上地址。$(RESET)"

# 本地开发快捷命令 (假设你已经在本机安装了Python和Node.js环境)
dev-backend:
	@if [ -d "./backend" ]; then \
		echo -e "$(CYAN)启动后端 Django 开发服务器...$(RESET)"; \
		cd backend && . venv/bin/activate && python manage.py runserver; \
	else \
		echo -e "$(RED)错误：后端目录 './backend' 不存在。请先完成第二阶段任务。$(RESET)"; \
	fi

dev-frontend:
	@if [ -d "./frontend" ]; then \
		echo -e "$(CYAN)启动前端 Vue 开发服务器...$(RESET)"; \
		cd frontend && npm run dev; \
	else \
		echo -e "$(RED)错误：前端目录 './frontend' 不存在。请先完成第七阶段任务。$(RESET)"; \
	fi

# 测试服务连接
test:
	@echo -e "$(CYAN)测试服务连接...$(RESET)"
	@echo -e "$(YELLOW)1. 测试PostgreSQL连接...$(RESET)"
	@if docker-compose exec postgres pg_isready -U fx_user -d fx_trading_dev > /dev/null 2>&1; then \
		echo -e "$(GREEN)✅ PostgreSQL连接正常$(RESET)"; \
	else \
		echo -e "$(RED)❌ PostgreSQL连接失败$(RESET)"; \
	fi
	@echo ""
	@echo -e "$(YELLOW)2. 测试Redis连接...$(RESET)"
	@if docker-compose exec redis redis-cli ping | grep -q PONG; then \
		echo -e "$(GREEN)✅ Redis连接正常$(RESET)"; \
	else \
		echo -e "$(RED)❌ Redis连接失败$(RESET)"; \
	fi
	@echo ""
	@echo -e "$(YELLOW)3. 测试MinIO连接...$(RESET)"
	@if curl -s http://localhost:9000/minio/health/live > /dev/null; then \
		echo -e "$(GREEN)✅ MinIO连接正常$(RESET)"; \
	else \
		echo -e "$(RED)❌ MinIO连接失败$(RESET)"; \
		echo -e "$(YELLOW)如果服务刚启动，请等待几秒钟后重试。$(RESET)"; \
	fi
	@echo ""
	@echo -e "$(CYAN)服务详情:$(RESET)"
	@echo -e "$(YELLOW)PostgreSQL:$(RESET) localhost:5432 (fx_trading_dev)"
	@echo -e "$(YELLOW)Redis:$(RESET) localhost:6379"
	@echo -e "$(YELLOW)MinIO:$(RESET) Console: http://localhost:9001, API: http://localhost:9000"
	@echo -e "$(GREEN)✅ 所有服务连接测试完成$(RESET)"

# 系统状态概览
status:
	@echo -e "$(CYAN)=== 外汇交易系统状态概览 ===$(RESET)"
	@echo ""
	@echo -e "$(GREEN)1. Docker 服务状态:$(RESET)"
	@docker-compose ps
	@echo ""
	@echo -e "$(GREEN)2. 磁盘空间使用:$(RESET)"
	@docker system df
	@echo ""
	@echo -e "$(GREEN)3. 最近日志:$(RESET)"
	@docker-compose logs --tail=5 2>/dev/null | grep -v "^$" || echo -e "$(YELLOW)暂无日志$(RESET)"
	@echo ""
	@echo -e "$(GREEN)4. 关键文件检查:$(RESET)"
	@[ -f ".env" ] && echo -e "$(GREEN)✅ .env 文件存在$(RESET)" || echo -e "$(YELLOW)⚠️  .env 文件不存在 (运行 'make init' 创建)$(RESET)"
	@[ -f "docker-compose.yml" ] && echo -e "$(GREEN)✅ docker-compose.yml 存在$(RESET)" || echo -e "$(RED)❌ docker-compose.yml 不存在$(RESET)"
	@[ -f "Makefile" ] && echo -e "$(GREEN)✅ Makefile 存在$(RESET)" || echo -e "$(RED)❌ Makefile 不存在$(RESET)"
	@echo ""
	@echo -e "$(CYAN)使用 'make help' 查看所有可用命令$(RESET)"