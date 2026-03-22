#!/bin/bash
# 上传单个文档到语雀

set -e

CONFIG_FILE="$HOME/.config/yuque-upload/config.json"

# 显示帮助
if [ $# -lt 1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "📤 语雀文档上传"
    echo ""
    echo "用法:"
    echo "  $0 <markdown文件> [选项]"
    echo ""
    echo "选项:"
    echo "  -t, --title <title>    指定文档标题 (默认使用文件名)"
    echo "  -r, --repo <repo>      指定知识库 (默认使用配置中的知识库)"
    echo "  -s, --slug <slug>      指定文档 URL 别名"
    echo ""
    echo "示例:"
    echo "  $0 ./my-document.md"
    echo "  $0 ./my-document.md -t \"我的文档\" -r zhangfan-9eaud/my-repo"
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

# 解析参数
MD_FILE="$1"
shift

TITLE=""
REPO=""
SLUG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--title)
            TITLE="$2"
            shift 2
            ;;
        -r|--repo)
            REPO="$2"
            shift 2
            ;;
        -s|--slug)
            SLUG="$2"
            shift 2
            ;;
        *)
            echo "❌ 未知选项: $1"
            exit 1
            ;;
    esac
done

# 检查文件
if [ ! -f "$MD_FILE" ]; then
    echo "❌ 文件不存在: $MD_FILE"
    exit 1
fi

# 设置默认值
if [ -z "$REPO" ]; then
    REPO="$DEFAULT_REPO"
fi

if [ -z "$REPO" ]; then
    echo "❌ 未指定知识库，请使用 -r 参数或运行 setup 配置默认知识库"
    exit 1
fi

if [ -z "$TITLE" ]; then
    TITLE=$(basename "$MD_FILE" .md)
fi

if [ -z "$SLUG" ]; then
    SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
fi

echo "📤 上传文档到语雀"
echo "================"
echo "  文件: $MD_FILE"
echo "  标题: $TITLE"
echo "  别名: $SLUG"
echo "  知识库: $REPO"

# 读取文件内容
echo ""
echo "📖 读取文件内容..."
BODY=$(cat "$MD_FILE")

# 创建临时 JSON 文件
echo "📝 准备上传数据..."
python3 <> PYEOF
import json
import sys

data = {
    "title": "$TITLE",
    "slug": "$SLUG",
    "format": "markdown",
    "body": """$BODY"""
}

with open('/tmp/yuque_upload.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False)
PYEOF

# 上传
echo "☁️  上传中..."
RESPONSE=$(curl -s -X POST \
    -H "X-Auth-Token: $TOKEN" \
    -H "Content-Type: application/json" \
    -d @/tmp/yuque_upload.json \
    "https://www.yuque.com/api/v2/repos/$REPO/docs")

# 检查响应
if echo "$RESPONSE" | grep -q '"data"'; then
    DOC_URL=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
doc = data.get('data', {})
print(f\"https://www.yuque.com/{doc.get('book', {}).get('user', {}).get('login', '')}/{doc.get('book', {}).get('slug', '')}/{doc.get('slug', '')}\")
")
    echo ""
    echo "✅ 上传成功!"
    echo "   链接: $DOC_URL"
else
    echo ""
    echo "❌ 上传失败"
    echo "错误信息:"
    echo "$RESPONSE" | python3 -c "import sys, json; print(json.dumps(json.load(sys.stdin), indent=2, ensure_ascii=False))" 2>/dev/null || echo "$RESPONSE"
    exit 1
fi
