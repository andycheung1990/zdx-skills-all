#!/bin/bash
# 语雀配置初始化脚本

set -e

echo "☁️  语雀文档上传工具 - 配置向导"
echo "================================"

CONFIG_DIR="$HOME/.config/yuque-upload"
CONFIG_FILE="$CONFIG_DIR/config.json"

# 创建配置目录
mkdir -p "$CONFIG_DIR"

echo ""
echo "📝 请输入语雀 API Token"
echo "   获取方式: https://www.yuque.com/settings/tokens"
read -s -p "Token: " TOKEN
echo ""

if [ -z "$TOKEN" ]; then
    echo "❌ Token 不能为空"
    exit 1
fi

# 验证 Token
echo ""
echo "🔍 验证 Token..."
USER_INFO=$(curl -s -H "X-Auth-Token: $TOKEN" https://www.yuque.com/api/v2/user)

if echo "$USER_INFO" | grep -q "error"; then
    echo "❌ Token 验证失败，请检查 Token 是否正确"
    exit 1
fi

USER_NAME=$(echo "$USER_INFO" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('name', 'Unknown'))")
USER_LOGIN=$(echo "$USER_INFO" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('login', 'Unknown'))")

echo "✅ Token 验证成功!"
echo "   用户: $USER_NAME ($USER_LOGIN)"

# 获取知识库列表
echo ""
echo "📚 获取知识库列表..."
REPOS=$(curl -s -H "X-Auth-Token: $TOKEN" "https://www.yuque.com/api/v2/users/$USER_LOGIN/repos")

echo ""
echo "可用的知识库:"
echo "$REPOS" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for i, repo in enumerate(data.get('data', []), 1):
    print(f\"  {i}. {repo['name']} ({repo['namespace']})\")
"

# 选择默认知识库
echo ""
read -p "请选择默认知识库 (输入序号): " REPO_INDEX

SELECTED_REPO=$(echo "$REPOS" | python3 -c "
import sys, json
data = json.load(sys.stdin)
repos = data.get('data', [])
index = int('$REPO_INDEX') - 1
if 0 <= index < len(repos):
    print(repos[index]['namespace'])
else:
    print('')
")

if [ -z "$SELECTED_REPO" ]; then
    echo "❌ 选择无效"
    exit 1
fi

echo "✅ 已选择: $SELECTED_REPO"

# 保存配置
echo ""
echo "💾 保存配置..."

cat > "$CONFIG_FILE" << EOF
{
  "token": "$TOKEN",
  "defaultRepo": "$SELECTED_REPO",
  "userLogin": "$USER_LOGIN",
  "userName": "$USER_NAME",
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

chmod 600 "$CONFIG_FILE"

echo "✅ 配置已保存到: $CONFIG_FILE"
echo ""
echo "使用提示:"
echo "  - 上传文档: yuque-upload upload <markdown文件>"
echo "  - 批量上传: yuque-upload upload-batch <目录>"
echo "  - 查看知识库: yuque-upload list-repos"
