# 外汇交易订单管理系统 (FX Trading System)

一个基于Django REST Framework和Vue3的全栈Web应用，用于管理和分析外汇交易订单。

## ✨ 核心功能
- ✅ 用户认证与多账户管理
- 📊 手动录入与CSV批量导入订单（支持MT4/MT5格式）
- 🔍 订单的检索、筛选、分页与修改
- 📈 核心交易KPI计算（盈亏、胜率、最大回撤等）与可视化图表
- ⚙️ 系统设置、数据备份与审计日志

## 🛠️ 技术栈
- **后端**: Python, Django, Django REST Framework, PostgreSQL, Redis, Celery, MinIO
- **前端**: Vue 3, TypeScript, Pinia, Vue Router, Element Plus, ECharts
- **开发运维**: Docker, Docker Compose, Nginx, Git

## 🚀 快速开始 (开发环境)

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd fx-trading-system
    ```
2. **启动基础设施**
    ```bash
    docker-compose up -d postgres redis minio
    ```
3. **设置后端**
    ```bash
    cd backend
    python -m venv venv
    source venv/bin/activate  # Windows: venv\Scripts\activate
    pip install -r requirements.txt
    python manage.py migrate
    python manage.py runserver
   ```
4. **设置前端**
    ```bash
    cd frontend
    npm install
    npm run dev
    ```
5. 访问 http://localhost:5173
    
📁 项目结构
```text

fx-trading-system/
├── backend/          # Django 后端项目
├── frontend/         # Vue3 前端项目
├── docker/           # 各服务的Docker配置文件
├── scripts/          # 部署与实用脚本
└── docs/             # 项目文档
```
📄 许可证
本项目基于 MIT 许可证开源。