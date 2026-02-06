#!/bin/bash
# 重置开发数据库
docker-compose down -v
docker-compose up -d postgres redis
sleep 5
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py loaddata fixtures/initial_data.json