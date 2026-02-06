#!/bin/bash
# 开发环境一键设置脚本
echo "设置开发环境..."
docker-compose build
docker-compose up -d
echo "执行数据库迁移..."
docker-compose exec backend python manage.py migrate
echo "创建超级用户..."
docker-compose exec backend python manage.py createsuperuser