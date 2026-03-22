#!/bin/bash
# 认证和配对配置脚本

set -e

echo "🔐 认证和配对配置"
echo "=================="

# 生成随机 token
TOKEN=$(openssl rand -hex 20)

echo ""
echo "📝 生成 Token: $$TOKEN"

# 检查配置文件
if [ ! -f "$HOME/.openclaw/openclaw.json" ]; then
    echo "❌ 配置文件不存在，请先启动 OpenClaw"
    exit 1
fi

# 备份配置
cp "$HOME/.openclaw/openclaw.json" "$HOME/.openclaw/openclaw.json.bak"

echo ""
echo "📝 更新认证配置..."

# 使用临时文件更新 JSON
python3 << PYTHON
import json
import sys

config_path = "$HOME/.openclaw/openclaw.json"

with open(config_path, 'r') as f:
    config = json.load(f)

# 更新 gateway 配置
if 'gateway' not in config:
    config['gateway'] = {}

config['gateway']['bind'] = 'lan'
config['gateway']['auth'] = {
    'mode': 'token',
    'token': '$$TOKEN'
}

if 'controlUi' not in config['gateway']:
    config['gateway']['controlUi'] = {}

config['gateway']['controlUi']['allowedOrigins'] = [
    'http://localhost:18789',
    'http://127.0.0.1:18789'
]

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print('✅ 配置已更新')
PYTHON

# 重启容器
echo ""
echo "🔄 重启 OpenClaw 容器..."
docker restart openclaw

sleep 3

echo ""
echo "✅ 认证配置完成!"
echo ""
echo "Token: $$TOKEN"
echo ""
echo "访问方式:"
echo "  1. 打开 http://localhost:18791/"
echo "  2. 输入 Gateway URL: ws://localhost:18789"
echo "  3. 输入 Token: $$TOKEN"
echo ""
echo "或在浏览器控制台执行:"
echo "  localStorage.setItem('gateway:url', 'ws://localhost:18789');"
echo "  localStorage.setItem('gateway:token', '$$TOKEN');"
