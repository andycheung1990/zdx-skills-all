#!/bin/bash
# 腾讯云模型配置脚本

set -e

echo "☁️  腾讯云模型配置"
echo "=================="

# 检查目录
if [ ! -d "$HOME/.openclaw" ]; then
    echo "❌ OpenClaw 配置目录不存在，请先运行 Docker 部署"
    exit 1
fi

# 获取 API Key
echo ""
read -p "请输入腾讯云 API Key: " API_KEY

if [ -z "$$API_KEY" ]; then
    echo "❌ API Key 不能为空"
    exit 1
fi

# 创建模型配置
echo ""
echo "📝 创建模型配置文件..."

cat > "$HOME/.openclaw/config/models.json" << 'EOF'
{
  "models": {
    "mode": "merge",
    "providers": {
      "tencent-coding-plan": {
        "baseUrl": "https://api.lkeap.cloud.tencent.com/coding/v3",
        "apiKey": "YOUR_API_KEY_HERE",
        "api": "openai-completions",
        "models": [
          {
            "id": "tc-code-latest",
            "name": "Auto",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 196608,
            "maxTokens": 32768
          },
          {
            "id": "hunyuan-2.0-instruct",
            "name": "Tencent HY 2.0 Instruct",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 128000,
            "maxTokens": 16000
          },
          {
            "id": "hunyuan-2.0-thinking",
            "name": "Tencent HY 2.0 Think",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 128000,
            "maxTokens": 32000
          },
          {
            "id": "hunyuan-t1",
            "name": "Hunyuan-T1",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 64000,
            "maxTokens": 32000
          },
          {
            "id": "hunyuan-turbos",
            "name": "hunyuan-turbos",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 32000,
            "maxTokens": 16000
          },
          {
            "id": "minimax-m2.5",
            "name": "MiniMax-M2.5",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 196608,
            "maxTokens": 32768
          },
          {
            "id": "kimi-k2.5",
            "name": "Kimi-K2.5",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 262144,
            "maxTokens": 32768
          },
          {
            "id": "glm-5",
            "name": "GLM-5",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 202752,
            "maxTokens": 16384
          }
        ]
      }
    }
  }
}
EOF

# 替换 API Key
sed -i.bak "s/YOUR_API_KEY_HERE/$$API_KEY/g" "$HOME/.openclaw/config/models.json"
rm -f "$HOME/.openclaw/config/models.json.bak"

# 复制到主目录
cp "$HOME/.openclaw/config/models.json" "$HOME/.openclaw/models.json"

echo "✅ 模型配置已创建"

# 更新主配置
echo ""
echo "📝 更新主配置文件..."

if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    # 备份原配置
    cp "$HOME/.openclaw/openclaw.json" "$HOME/.openclaw/openclaw.json.bak"

    # 合并模型配置（这里使用简单的方式，实际可能需要更复杂的 JSON 合并）
    echo "⚠️  请手动将模型配置合并到 ~/.openclaw/openclaw.json"
else
    echo "❌ 主配置文件不存在，请先启动 OpenClaw"
    exit 1
fi

# 重启容器
echo ""
echo "🔄 重启 OpenClaw 容器..."
docker restart openclaw

sleep 3

# 验证
echo ""
echo "🔍 验证配置..."
if docker logs openclaw 2>&1 | grep -q "tencent-coding-plan"; then
    echo "✅ 腾讯云模型配置成功!"
    echo ""
    echo "可用模型:"
    echo "  - tc-code-latest (Auto)"
    echo "  - hunyuan-2.0-instruct"
    echo "  - hunyuan-2.0-thinking"
    echo "  - hunyuan-t1"
    echo "  - hunyuan-turbos"
    echo "  - minimax-m2.5"
    echo "  - kimi-k2.5"
    echo "  - glm-5"
else
    echo "⚠️  配置可能未生效，请检查日志: docker logs openclaw"
fi
