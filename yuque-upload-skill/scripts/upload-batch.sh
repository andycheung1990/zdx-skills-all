#!/bin/bash
# 批量上传文档到语雀

set -e

CONFIG_FILE="$HOME/.config/yuque-upload/config.json"

# 显示帮助
if [ $# -lt 1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "📦 语雀批量文档上传"
    echo ""
    echo "用法:"
    echo "  $0 <目录> [选项]"
    echo ""
    echo "选项:"
    echo "  -r, --repo <repo>      指定知识库 (默认使用配置中的知识库)"
    echo "  --dry-run              模拟运行，不实际上传"
    echo ""
    echo "示例:"
    echo "  $0 ./docs"
    echo "  $0 ./docs -r zhangfan-9eaud/my-repo"
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
DIR="$1"
shift

REPO=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--repo)
            REPO="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "❌ 未知选项: $1"
            exit 1
            ;;
    esac
done

# 检查目录
if [ ! -d "$DIR" ]; then
    echo "❌ 目录不存在: $DIR"
    exit 1
fi

# 设置默认知识库
if [ -z "$REPO" ]; then
    REPO="$DEFAULT_REPO"
fi

if [ -z "$REPO" ]; then
    echo "❌ 未指定知识库，请使用 -r 参数或运行 setup 配置默认知识库"
    exit 1
fi

echo "📦 批量上传文档到语雀"
echo "===================="
echo "  目录: $DIR"
echo "  知识库: $REPO"
if [ "$DRY_RUN" = true ]; then
    echo "  模式: 模拟运行 (dry-run)"
fi
echo ""

# 查找所有 markdown 文件
MD_FILES=$(find "$DIR" -name "*.md" -type f)

if [ -z "$MD_FILES" ]; then
    echo "❌ 未找到 Markdown 文件"
    exit 1
fi

# 统计文件数量
FILE_COUNT=$(echo "$MD_FILES" | wc -l | tr -d ' ')
echo "找到 $FILE_COUNT 个 Markdown 文件"
echo ""

# 上传计数
SUCCESS_COUNT=0
FAILED_COUNT=0

# 遍历上传
for FILE in $MD_FILES; do
    FILENAME=$(basename "$FILE")
    TITLE=$(basename "$FILE" .md)
    SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

    echo "📤 上传: $FILENAME"
    echo "   标题: $TITLE"
    echo "   别名: $SLUG"

    if [ "$DRY_RUN" = true ]; then
        echo "   [模拟] 跳过上传"
        ((SUCCESS_COUNT++))
    else
        # 读取文件内容
        BODY=$(cat "$FILE")

        # 创建临时 JSON
        python3 <> PYEOF
import json

data = {
    "title": "$TITLE",
    "slug": "$SLUG",
    "format": "markdown",
    "body": """$BODY"""
}

with open('/tmp/yuque_upload_batch.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False)
PYEOF

        # 上传
        RESPONSE=$(curl -s -X POST \
            -H "X-Auth-Token: $TOKEN" \
            -H "Content-Type: application/json" \
            -d @/tmp/yuque_upload_batch.json \
            "https://www.yuque.com/api/v2/repos/$REPO/docs")

        # 检查响应
        if echo "$RESPONSE" | grep -q '"data"'; then
            DOC_URL=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
doc = data.get('data', {})
print(f\"https://www.yuque.com/{doc.get('book', {}).get('user', {}).get('login', '')}/{doc.get('book', {}).get('slug', '')}/{doc.get('slug', '')}\")
")
            echo "   ✅ 成功: $DOC_URL"
            ((SUCCESS_COUNT++))
        else
            echo "   ❌ 失败"
            ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('message', 'Unknown error'))" 2>/dev/null || echo "Unknown error")
            echo "      错误: $ERROR_MSG"
            ((FAILED_COUNT++))
        fi
    fi
    echo ""
done

echo "===================="
echo "📊 上传统计"
echo "===================="
echo "  成功: $SUCCESS_COUNT"
echo "  失败: $FAILED_COUNT"
echo "  总计: $FILE_COUNT"

if [ $FAILED_COUNT -gt 0 ]; then
    exit 1
fi
