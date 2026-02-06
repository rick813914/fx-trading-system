#!/bin/bash

echo "=== 外汇交易订单管理系统 - 开发环境检查 ==="
echo "检查时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_command() {
    local cmd=$1
    local name=$2
    local required=${3:-true}

    if command -v $cmd &> /dev/null; then
        local version=$($cmd --version 2>/dev/null | head -n1 | awk '{print $NF}' | tr -d ',')
        echo -e "   ${GREEN}✓${NC} $name已安装 - 版本: $version"
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "   ${RED}✗${NC} $name未安装 - 必需组件"
            return 1
        else
            echo -e "   ${YELLOW}⚠${NC} $name未安装 - 可选组件"
            return 0
        fi
    fi
}

# 检查Git
echo "1. 检查版本控制..."
check_command git "Git"

# 检查Docker和Docker Compose
echo "2. 检查容器化工具..."
check_command docker "Docker"
check_command docker-compose "Docker Compose"

# 检查Python
echo "3. 检查Python环境..."
check_command python3 "Python3"
check_command pip3 "pip"

# 检查Node.js（前端开发）
echo "4. 检查前端开发环境..."
check_command node "Node.js" "false"
if command -v node &> /dev/null; then
    node_version=$(node --version | tr -d 'v')
    npm_version=$(npm --version)
    echo -e "   ${GREEN}✓${NC} Node版本: $node_version"
    echo -e "   ${GREEN}✓${NC} npm版本: $npm_version"
fi

# 检查目录结构
echo "5. 检查项目目录结构..."
echo "   项目根目录: $(pwd)"
echo ""

required_dirs=("frontend" "backend" "docs" "scripts" "docker" "infrastructure")
missing_dirs=()

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "   ${GREEN}✓${NC} 目录存在: $dir"
    else
        echo -e "   ${RED}✗${NC} 目录缺失: $dir"
        missing_dirs+=("$dir")
    fi
done

# 检查关键文件
echo ""
echo "6. 检查关键配置文件..."
key_files=("docker-compose.yml" "Makefile" "README.md" ".gitignore")
for file in "${key_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "   ${GREEN}✓${NC} 文件存在: $file"
    else
        echo -e "   ${YELLOW}⚠${NC} 文件缺失: $file"
    fi
done

# 检查.env文件
echo ""
echo "7. 检查环境配置文件..."
if [ -f ".env.development" ] || [ -f ".env" ]; then
    echo -e "   ${GREEN}✓${NC} 环境配置文件存在"
else
    echo -e "   ${YELLOW}⚠${NC} 环境配置文件缺失 (.env 或 .env.development)"
    echo -e "     请复制 .env.example 创建环境配置文件"
fi

# 总结
echo ""
echo "=== 检查完成 ==="
echo ""

if [ ${#missing_dirs[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ 所有必需目录都存在${NC}"
else
    echo -e "${YELLOW}⚠  缺失目录: ${missing_dirs[*]}${NC}"
    echo "   请按照项目文档创建缺失的目录结构"
fi

echo ""
echo "下一步建议:"
echo "1. 运行 'make dev-up' 启动开发环境"
echo "2. 运行 'make test' 执行测试"
echo "3. 查看 docs/development/setup.md 获取完整设置指南"