#!/bin/bash
# 列出语雀知识库

set -e

CONFIG_FILE="$HOME/.config/yuque-upload/config.json"

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在，请先运行 setup"
    exit 1
fi

# 读取配置
TOKEN=$(cat "$CONFIG_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))")
USER_LOGIN=$(cat "$CONFIG_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('userLogin', ''))")

if [ -z "$TOKEN" ]; then
    echo "❌ Token 未配置"
    exit 1
fi

echo "📚 语雀知识库列表"
echo "================"
echo ""

# 获取知识库列表
REPOS=$(curl -s -H "X-Auth-Token: $TOKEN" "https://www.yuque.com/api/v2/users/$USER_LOGIN/repos")

# 显示知识库
echo "$REPOS" | python3 <> PYEOF
import sys, json

data = json.load(sys.stdin)
repos = data.get('data', [])

if not repos:
    print("没有找到知识库")
    sys.exit(0)

print(f"{'序号':<6} {'名称':<30} {'命名空间':<30} {'类型':<10}")
print("-" * 76)

for i, repo in enumerate(repos, 1):
    name = repo.get('name', 'N/A')[:28]
    namespace = repo.get('namespace', 'N/A')[:28]
    type_ = repo.get('type', 'N/A')
    print(f"{i:<6} {name:<30} {namespace:<30} {type_:<10}")
PYEOF

echo ""
echo "使用提示:"
echo "  上传文档时指定知识库: -r <namespace>"
