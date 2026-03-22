# OpenClaw Docker 部署 Skill

一键部署 OpenClaw 到 Docker 并配置腾讯云模型。

## 安装

```bash
# 克隆或下载此 skill
# 将 skill 目录放置到 ~/.openclaw/skills/
cp -r openclaw-docker-skill ~/.openclaw/skills/
```

## 使用

### 1. 部署 Docker

```bash
openclaw skill run openclaw-docker-setup setup-docker
```

或手动运行脚本：
```bash
chmod +x scripts/setup-docker.sh
./scripts/setup-docker.sh
```

### 2. 配置腾讯云模型

```bash
openclaw skill run openclaw-docker-setup setup-tencent-cloud
```

或手动运行：
```bash
chmod +x scripts/setup-tencent-cloud.sh
./scripts/setup-tencent-cloud.sh
```

### 3. 配置认证

```bash
openclaw skill run openclaw-docker-setup configure-auth
```

### 4. 问题排查

```bash
openclaw skill run openclaw-docker-setup troubleshoot
```

## 文件结构

```
openclaw-docker-skill/
├── skill.json                 # Skill 配置
├── README.md                  # 说明文档
├── scripts/
│   ├── setup-docker.sh        # Docker 部署脚本
│   ├── setup-tencent-cloud.sh # 腾讯云配置脚本
│   ├── configure-auth.sh      # 认证配置脚本
│   └── troubleshoot.sh        # 问题排查脚本
├── config/
│   └── openclaw.json.template # 配置模板
└── docs/
    └── setup-guide.md         # 完整配置手册
```

## 依赖

- Docker 20.10+
- OpenClaw 2026.3.13+
- Python 3 (用于配置脚本)

## 许可

MIT License
