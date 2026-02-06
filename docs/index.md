# 项目文档索引

## 📚 项目文档

### 项目概览
- [项目介绍](../README.md)
- [变更日志](../CHANGELOG.md)
- [许可证](../LICENSE)

### 架构设计
- [系统架构设计](./architecture/system-architecture.md)
- [数据库设计](./architecture/database-design.md)
- [API设计](./architecture/api-design.md)
- [部署架构](./architecture/deployment-architecture.md)

### 开发指南
- [环境搭建](./development/setup.md)
- [编码规范](./development/coding-standards.md)
- [Git工作流](./development/git-workflow.md)
- [测试指南](./development/testing.md)
- [调试指南](./development/debugging.md)

### API文档
- [API概览](./api/overview.md)
- [认证说明](./api/authentication.md)
- [API端点](./api/endpoints/)

### 用户指南
- [快速开始](./user-guide/getting-started.md)
- [功能说明](./user-guide/features/)
- [常见问题](./user-guide/faq.md)

### 部署指南
- [本地开发部署](./deployment/local-development.md)
- [生产部署](./deployment/production-deployment.md)
- [Docker部署](./deployment/docker.md)
- [Kubernetes部署](./deployment/kubernetes.md)

### 运维指南
- [监控指南](./operations/monitoring.md)
- [备份恢复](./operations/backup-recovery.md)
- [故障排查](./operations/troubleshooting.md)
- [性能调优](./operations/performance-tuning.md)

### 需求文档
- [用户故事](./requirements/user-stories.md)
- [功能需求](./requirements/functional-requirements.md)
- [非功能需求](./requirements/non-functional-requirements.md)
- [优先级列表](./requirements/prioritization.md)

### 技术决策
- [技术栈选择](./decisions/001-tech-stack-selection.md)
- [数据库选择](./decisions/002-database-selection.md)
- [API设计决策](./decisions/003-api-design.md)

## 📁 项目结构

fx-trading-system/
├── frontend/ # Vue.js 3前端应用
├── backend/ # Django后端API
├── infrastructure/ # IaC配置
├── docs/ # 项目文档
├── scripts/ # 工具脚本
├── tests/ # 测试
├── docker/ # Docker配置
└── .github/ # GitHub工作流
text


## 🔧 快速命令
```bash
# 启动开发环境
make dev-up

# 停止开发环境
make dev-down

# 测试服务
make test

# 查看日志
make logs
```