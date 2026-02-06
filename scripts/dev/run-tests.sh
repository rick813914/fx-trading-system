#!/bin/bash
# 运行所有测试
echo "运行后端测试..."
docker-compose exec backend pytest
echo "运行前端测试..."
cd frontend && npm test