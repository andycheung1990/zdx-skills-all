#!/bin/bash
# 列出语雀知识库中的文档

set -e

CONFIG_FILE="$HOME/.config/yuque-upload/config.json"

# 显示帮助
if [ $# -lt 1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "📄 列出语雀知识库中的文档"
    echo ""
    echo "用法:"
    echo "  $0 <repo>"
    echo ""
    echo "参数:"
    echo "  repo    知识库命名空间 (如: zhangfan-9eaud/my-repo)"
    echo ""
    echo "示例:"
    echo "  $0 zhangfan-9eaud/peuqzm"
    exit 0
fi

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在，请先运行 setup"
    exit 1
fi

# 读取配置
TOKEN=$(cat "$CONFIG_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))")
DEFAULT_REPO=$(cat "$CONFIG_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('defaultRepo', ''))")

if [ -z "$TOKEN" ]; then
    echo "❌ Token 未配置"
    exit 1
fi

# 获取知识库参数
REPO="$1"

if [ -z "$REPO" ]; then
    REPO="$DEFAULT_REPO"
fi

if [ -z "$REPO" ]; then
    echo "❌ 未指定知识库"
    exit 1
fi

echo "📄 知识库文档列表"
echo "================"
echo "  知识库: $REPO"
echo ""

# 获取文档列表
DOCS=$(curl -s -H "X-Auth-Token: $TOKEN" "https://www.yuque.com/api/v2/repos/$REPO/docs")

# 检查错误
if echo "$DOCS" | grep -q '"message"'; then
    ERROR=$(echo "$DOCS" | python3 -c "import sys, json; print(json.load(sys.stdin).get('message', 'Unknown error'))" 2>/dev/null || echo "Unknown error")
    echo "❌ 获取失败: $ERROR"
    exit 1
fi

# 显示文档
echo "$DOCS" | python3 <> PYEOF
import sys, json

data = json.load(sys.stdin)
docs = data.get('data', [])

if not docs:
    print("没有找到文档")
    sys.exit(0)

print(f"{'序号':<6} {'标题':<40} {'Slug':<30} {'更新时间':<20}")
print("-" * 96)

for i, doc in enumerate(docs, 1):
    title = doc.get('title', 'N/A')[:38]
    slug = doc.get('slug', 'N/A')[:28]
    updated = doc.get('updated_at', 'N/A')[:18]
    print(f"{i:<6} {title:<40} {slug:<30} {updated:<20}")

print(f"\n总计: {len(docs)} 篇文档")
PYEOF
