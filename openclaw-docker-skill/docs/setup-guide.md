# OpenClaw Docker 部署与腾讯云配置手册

## 目录
1. [环境准备](#环境准备)
2. [Docker 安装 OpenClaw](#docker-安装-openclaw)
3. [腾讯云模型配置](#腾讯云模型配置)
4. [认证与配对配置](#认证与配对配置)
5. [常见问题排查](#常见问题排查)

---

## 环境准备

### 检查 Docker 安装
```bash
# 检查 Docker 版本
docker --version

# 检查 Docker 服务状态
docker info
```

### 系统要求
- Docker 20.10+
- 内存：4GB+
- 磁盘空间：2GB+

---

## Docker 安装 OpenClaw

### 1. 拉取镜像

```bash
docker pull ghcr.io/openclaw/openclaw:latest
```

镜像大小约 1.89GB，下载时间取决于网络速度。

### 2. 创建配置目录

```bash
mkdir -p ~/.openclaw/config
mkdir -p ~/.openclaw/data
chmod -R 777 ~/.openclaw
```

### 3. 启动容器

```bash
docker run -d --name openclaw \
  -p 18789:18789 \
  -p 18791:18791 \
  -v ~/.openclaw:/home/node/.openclaw \
  ghcr.io/openclaw/openclaw:latest
```

### 4. 验证运行状态

```bash
# 查看容器状态
docker ps | grep openclaw

# 查看日志
docker logs openclaw

# 查看端口映射
docker port openclaw
```

**预期输出：**
```
18789/tcp -> 0.0.0.0:18789
18791/tcp -> 0.0.0.0:18791
```

---

## 腾讯云模型配置

### 1. 创建模型配置文件

创建文件 `~/.openclaw/config/models.json`：

```json
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
```

### 2. 复制配置文件到主目录

```bash
cp ~/.openclaw/config/models.json ~/.openclaw/models.json
```

### 3. 配置主配置文件

编辑 `~/.openclaw/openclaw.json`，添加模型配置：

```json
{
  "gateway": {
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "your-secure-token"
    },
    "controlUi": {
      "allowedOrigins": [
        "http://localhost:18789",
        "http://127.0.0.1:18789"
      ]
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "tencent-coding-plan": {
        "baseUrl": "https://api.lkeap.cloud.tencent.com/coding/v3",
        "apiKey": "YOUR_API_KEY_HERE",
        "api": "openai-completions",
        "models": [
          // ... 模型列表见上文
        ]
      }
    }
  }
}
```

### 4. 重启容器

```bash
docker restart openclaw
```

### 5. 验证配置

```bash
# 查看日志确认模型加载
docker logs openclaw | grep "tencent-coding-plan"
```

**预期输出：**
```
[gateway] agent model: tencent-coding-plan/tc-code-latest
```

---

## 认证与配对配置

### 1. 获取 Gateway Token

从配置文件中获取：
```bash
cat ~/.openclaw/openclaw.json | grep token
```

### 2. 访问 Control UI

打开浏览器访问：
```
http://localhost:18791/
```

### 3. 初始配对

首次访问时需要进行设备配对：

1. 打开 http://localhost:18791/
2. 输入 Gateway URL: `ws://localhost:18789`
3. 输入 Token: `your-secure-token`
4. 点击 **Connect** 或 **Pair**

### 4. 批准配对请求

如果显示 "pairing required"，需要批准配对：

**方法 A：通过 CLI 批准（如果已安装 openclaw）**
```bash
openclaw pairing approve <pairing-code>
```

**方法 B：手动编辑设备文件**

查看待处理请求：
```bash
cat ~/.openclaw/devices/pending.json
```

复制待处理设备信息到 `~/.openclaw/devices/paired.json`，然后重启容器。

### 5. 清除浏览器缓存

如果遇到认证问题，清除缓存：
```javascript
// 在浏览器控制台执行
localStorage.clear();
sessionStorage.clear();
location.reload();
```

---

## 常见问题排查

### 问题 1：Connection reset by peer

**现象：** curl 测试连接被重置

**原因：** Gateway 绑定在 `127.0.0.1`，Docker 端口映射无法正常工作

**解决：** 修改配置使用 `bind: lan`：
```json
{
  "gateway": {
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "your-token"
    }
  }
}
```

### 问题 2：unauthorized: gateway token missing

**现象：** 浏览器显示需要 token

**解决：**
1. 访问带 token 的 URL：
   ```
   http://localhost:18789?token=YOUR_TOKEN
   ```
2. 或在浏览器控制台设置：
   ```javascript
   localStorage.setItem('gateway:token', 'YOUR_TOKEN');
   ```

### 问题 3：pairing required

**现象：** 已配对但仍提示需要配对

**解决：**
1. 检查 `~/.openclaw/devices/paired.json` 是否存在
2. 清除浏览器缓存后重新配对
3. 重启容器加载设备配置

### 问题 4：auth mode=none 不允许与 bind=lan 一起使用

**原因：** 安全限制，绑定到所有接口必须启用认证

**解决：** 要么使用 `bind: loopback` + `auth: none`，要么使用 `bind: lan` + `auth: token`

### 问题 5：腾讯云模型超时

**现象：** LLM request timed out

**解决：**
1. 检查 API Key 是否正确
2. 检查网络连接
3. 检查腾讯云控制台是否有访问限制

---

## 常用命令速查

```bash
# 启动容器
docker start openclaw

# 停止容器
docker stop openclaw

# 重启容器
docker restart openclaw

# 查看日志
docker logs openclaw -f

# 进入容器
docker exec -it openclaw sh

# 查看配置
docker exec openclaw cat /home/node/.openclaw/openclaw.json

# 删除容器（保留数据）
docker rm openclaw

# 完全删除（包括数据，谨慎使用）
docker rm -f openclaw
rm -rf ~/.openclaw
```

---

## 访问地址汇总

| 服务 | URL | 说明 |
|------|-----|------|
| Gateway WebSocket | `ws://localhost:18789` | WebSocket 连接地址 |
| Dashboard | `http://localhost:18789` | 主界面 |
| Control UI | `http://localhost:18791/` | 控制界面 |
| Canvas | `http://localhost:18789/__openclaw__/canvas/` | 画布服务 |

---

## 配置文件位置

| 文件 | 路径 | 说明 |
|------|------|------|
| 主配置 | `~/.openclaw/openclaw.json` | Gateway 和模型配置 |
| 模型配置 | `~/.openclaw/models.json` | 模型列表 |
| 配对设备 | `~/.openclaw/devices/paired.json` | 已配对设备 |
| 待配对 | `~/.openclaw/devices/pending.json` | 待处理配对请求 |
| 设备身份 | `~/.openclaw/identity/device.json` | 设备密钥 |

---

**版本信息：**
- 文档版本：v1.0
- 适用 OpenClaw 版本：2026.3.13+
- 更新时间：2026-03-22
