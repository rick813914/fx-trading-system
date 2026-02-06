# 环境搭建指南

## 系统要求

### 硬件要求

- CPU: 双核以上
    
- 内存: 4GB以上
    
- 磁盘: 10GB可用空间
    

### 软件要求

- **操作系统**: Windows 10/11, macOS 10.15+, Linux (Ubuntu 20.04+)
    
- **Docker Desktop/Engine**: 20.10+
    
- **Git**: 2.30+
    
- **Python**: 3.11+ (可选，用于本地开发)
    
- **Node.js**: 16+ (可选，用于前端开发)
    

## 安装步骤

### 1. 安装Docker

#### Windows/macOS

1. 访问 [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
    
2. 下载对应版本安装包
    
3. 安装并启动Docker Desktop
    
4. 确保WSL2已启用（Windows）
    

#### Linux (Ubuntu)

```bash

# 卸载旧版本
sudo apt-get remove docker docker-engine docker.io containerd runc

# 安装依赖
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 添加Docker官方GPG密钥
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 设置仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 验证安装
sudo docker run hello-world

# 添加用户到docker组（可选，避免每次sudo）
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```
### 2. 安装Git

#### Windows

下载安装Git for Windows: [https://git-scm.com/download/win](https://git-scm.com/download/win)

#### macOS

```bash
brew install git
```
#### Linux

```bash
sudo apt-get update
sudo apt-get install git
```
### 3. 获取项目代码

```bash
# 克隆项目
git clone https://github.com/rick813914/fx-trading-system.git
cd fx-trading-system

# 或使用SSH
git clone git@github.com:rick813914/fx-trading-system.git
cd fx-trading-system
```
### 4. 设置开发环境

```bash
# 运行环境检查
./scripts/check-env.sh

# 启动开发环境
make dev-up

# 验证服务
make test
```
### 5. 访问服务

- **PostgreSQL**: `localhost:5432`
    
    - 数据库: `fx_trading_dev`
        
    - 用户: `postgres`
        
    - 密码: `devpassword123`
        
- **Redis**: `localhost:6379`
    
- **MinIO控制台**: [http://localhost:9001](http://localhost:9001)
    
    - 用户名: `minioadmin`
        
    - 密码: `minioadmin123`
        
- **MinIO API**: [http://localhost:9000](http://localhost:9000)
    

## 常见问题

### Docker启动失败

**问题**: Docker Desktop无法启动  
**解决**:

1. 确保已启用虚拟化（BIOS设置）
    
2. Windows用户确保已启用WSL2
    
3. 重启计算机
    

### 端口冲突

**问题**: 端口5432、6379、9000、9001被占用  
**解决**:

1. 修改docker-compose.yml中的端口映射
    
2. 停止占用端口的进程
    

### 磁盘空间不足

**问题**: Docker镜像和容器占用过多空间  
**解决**:

```bash

# 清理未使用的镜像
docker system prune -a

# 清理所有未使用资源
docker system prune -a --volumes
```

### 网络问题

**问题**: 容器间无法通信  
**解决**:

1. 检查防火墙设置
    
2. 确保使用相同的Docker网络
    
3. 重启Docker服务
    

## 下一步

环境搭建完成后，可以开始：

1. 开发后端API：进入backend目录
    
2. 开发前端界面：进入frontend目录
    
3. 查看API文档：docs/api/overview.md
    
4. 学习开发规范：docs/development/coding-standards.md