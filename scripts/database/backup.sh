#!/bin/bash

# 数据库备份脚本

set -e

# 配置
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/fx_trading_backup_$TIMESTAMP.sql"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

echo "开始备份数据库..."

# 使用docker-compose执行备份
docker-compose exec -T postgres pg_dump -U postgres fx_trading_dev > "$BACKUP_FILE"

# 压缩备份文件
gzip "$BACKUP_FILE"

echo "备份完成: $BACKUP_FILE.gz"

# 保留最近7天的备份
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

echo "已清理7天前的旧备份。"