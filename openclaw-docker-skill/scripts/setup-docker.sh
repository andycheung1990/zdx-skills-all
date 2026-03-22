#!/bin/bash
# OpenClaw Docker 部署脚本

set -e

echo "🦞 OpenClaw Docker 部署脚本"
echo "=============================="

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

echo "✅ Docker 版本: $(docker --version)"

# 检查 Docker 服务
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 服务未运行，请启动 Docker"
    exit 1
fi

echo "✅ Docker 服务运行正常"

# 拉取镜像
echo ""
echo "📦 正在拉取 OpenClaw 镜像..."
docker pull ghcr.io/openclaw/openclaw:latest

# 创建配置目录
echo ""
echo "📁 创建配置目录..."
mkdir -p ~/.openclaw/config
mkdir -p ~/.openclaw/data
chmod -R 777 ~/.openclaw

# 检查是否已有容器
if docker ps -a | grep -q openclaw; then
    echo ""
    echo "⚠️  发现已有 OpenClaw 容器"
    read -p "是否删除并重新创建? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker stop openclaw 2>/dev/null || true
        docker rm openclaw 2>/dev/null || true
    else
        echo "取消部署"
        exit 0
    fi
fi

# 启动容器
echo ""
echo "🚀 启动 OpenClaw 容器..."
docker run -d --name openclaw \
  -p 18789:18789 \
  -p 18791:18791 \
  -v ~/.openclaw:/home/node/.openclaw \
  ghcr.io/openclaw/openclaw:latest

# 等待启动
echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 检查状态
if docker ps | grep -q openclaw; then
    echo ""
    echo "✅ OpenClaw 部署成功!"
    echo ""
    echo "访问地址:"
    echo "  Dashboard:    http://localhost:18789"
    echo "  Control UI:   http://localhost:18791/"
    echo "  Gateway WS:   ws://localhost:18789"
    echo ""
    echo "常用命令:"
    echo "  查看日志: docker logs openclaw -f"
    echo "  重启服务: docker restart openclaw"
    echo "  停止服务: docker stop openclaw"
else
    echo ""
    echo "❌ 部署失败，请检查日志:"
    echo "  docker logs openclaw"
    exit 1
fi
