#!/bin/bash

# 数据库恢复脚本

set -e

if [ -z "$1" ]; then
    echo "使用方法: $0 <备份文件>"
    echo "示例: $0 ./backups/fx_trading_backup_20240101_120000.sql.gz"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "错误: 备份文件不存在: $BACKUP_FILE"
    exit 1
fi

echo "警告: 这将覆盖当前数据库中的所有数据！"
read -p "确定要继续吗？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消。"
    exit 0
fi

echo "开始恢复数据库..."

# 解压备份文件（如果是gzip压缩的）
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "解压备份文件..."
    gunzip -c "$BACKUP_FILE" | docker-compose exec -T postgres psql -U postgres fx_trading_dev
else
    cat "$BACKUP_FILE" | docker-compose exec -T postgres psql -U postgres fx_trading_dev
fi

echo "数据库恢复完成！"