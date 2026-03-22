#!/bin/bash
# 问题排查脚本

echo "🔧 OpenClaw Docker 问题排查"
echo "============================"

echo ""
echo "1. 检查 Docker 状态..."
if docker ps | grep -q openclaw; then
    echo "   ✅ 容器正在运行"
    docker ps | grep openclaw
else
    echo "   ❌ 容器未运行"
    echo "   尝试启动: docker start openclaw"
fi

echo ""
echo "2. 检查端口映射..."
docker port openclaw 2>/dev/null || echo "   ❌ 无法获取端口映射"

echo ""
echo "3. 检查最近日志..."
echo "   最近 10 条日志:"
docker logs --tail 10 openclaw 2>&1 | sed 's/^/   /'

echo ""
echo "4. 检查配置文件..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    echo "   ✅ 主配置文件存在"
    echo "   配置内容预览:"
    cat "$HOME/.openclaw/openclaw.json" | head -20 | sed 's/^/   /'
else
    echo "   ❌ 主配置文件不存在"
fi

echo ""
echo "5. 检查网络连接..."
if curl -s http://localhost:18789 > /dev/null 2>&1; then
    echo "   ✅ 端口 18789 可访问"
else
    echo "   ❌ 端口 18789 无法访问"
fi

echo ""
echo "6. 检查设备配对..."
if [ -f "$HOME/.openclaw/devices/paired.json" ]; then
    echo "   ✅ 已配对设备:"
    cat "$HOME/.openclaw/devices/paired.json" | grep '"displayName"' | sed 's/^/   /'
else
    echo "   ⚠️  无配对设备文件"
fi

if [ -f "$HOME/.openclaw/devices/pending.json" ]; then
    echo "   ⚠️  有待处理配对请求:"
    cat "$HOME/.openclaw/devices/pending.json" | grep '"clientId"' | sed 's/^/   /'
fi

echo ""
echo "7. 常见修复建议..."
echo "   - 如果显示 'token missing': 访问 http://localhost:18789?token=YOUR_TOKEN"
echo "   - 如果显示 'pairing required': 清除浏览器缓存后重新配对"
echo "   - 如果连接被拒绝: 检查 Docker 端口映射和 bind 配置"
echo "   - 如果模型超时: 检查 API Key 和网络连接"

echo ""
echo "排查完成。如需更多帮助，请查看完整日志:"
echo "  docker logs openclaw -f"
