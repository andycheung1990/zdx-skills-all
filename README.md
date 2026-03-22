# ZDX Skills All

OpenClaw Skills 集合仓库

## Skills 列表

### 1. OpenClaw Docker Skill

一键部署 OpenClaw 到 Docker 并配置腾讯云模型。

**目录**: `openclaw-docker-skill/`

**功能**:
- Docker 一键部署
- 腾讯云模型配置
- 认证与配对配置
- 问题排查

**使用**:
```bash
cd openclaw-docker-skill
./scripts/setup-docker.sh
./scripts/setup-tencent-cloud.sh
./scripts/configure-auth.sh
```

**文档**: https://www.yuque.com/zhangfan-9eaud/peuqzm/openclaw-docker-guide

---

### 2. 语雀文档上传工具 (Yuque Upload)

一键将 Markdown 文档上传到语雀知识库。

**目录**: `yuque-upload-skill/`

**功能**:
- 语雀 API Token 配置
- 单文档上传
- 批量文档上传
- 知识库管理

**使用**:
```bash
cd yuque-upload-skill
./scripts/setup.sh                    # 配置 Token
./scripts/upload.sh ./my-doc.md       # 上传单个文档
./scripts/upload-batch.sh ./docs      # 批量上传
```

**文档**: https://www.yuque.com/zhangfan-9eaud/peuqzm/yuque-upload-skill

---

## 安装

```bash
# 克隆仓库
git clone https://github.com/andycheung1990/zdx-skills-all.git

# 安装 Skill
cd zdx-skills-all
cp -r openclaw-docker-skill ~/.openclaw/skills/
cp -r yuque-upload-skill ~/.openclaw/skills/

# 添加执行权限
chmod +x ~/.openclaw/skills/*/scripts/*.sh
```

---

## 依赖

- OpenClaw 2026.3.13+
- Docker 20.10+ (OpenClaw Docker Skill)
- Python 3.x
- curl

---

## 许可证

MIT License

---

**作者**: 张凡
**创建时间**: 2026-03-22
