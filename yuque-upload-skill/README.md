# 语雀文档上传工具 (Yuque Upload)

一键将 Markdown 文档上传到语雀知识库的 CLI 工具。

## 功能

- 🔐 安全的 API Token 管理
- 📤 单文档上传
- 📦 批量文档上传
- 📚 知识库管理
- 📄 文档列表查看
- 🎯 支持自定义标题、别名和知识库

## 安装

```bash
# 下载并解压
tar -xzf yuque-upload-skill-v1.0.0.tar.gz -C ~/.openclaw/skills/

# 添加执行权限
chmod +x ~/.openclaw/skills/yuque-upload-skill/scripts/*.sh
```

## 快速开始

### 1. 配置 Token

```bash
yuque-upload setup
```

输入你的语雀 API Token（从 https://www.yuque.com/settings/tokens 获取）

### 2. 上传文档

```bash
# 单文档上传
yuque-upload upload ./my-document.md

# 批量上传
yuque-upload upload-batch ./docs-directory
```

## 命令

| 命令 | 说明 |
|------|------|
| `setup` | 配置语雀 API Token |
| `upload` | 上传单个 Markdown 文档 |
| `upload-batch` | 批量上传目录中的 Markdown 文档 |
| `list-repos` | 列出可用的知识库 |
| `list-docs` | 列出知识库中的文档 |

## 使用示例

```bash
# 配置工具
yuque-upload setup

# 上传单个文档
yuque-upload upload ./README.md

# 上传并指定标题
yuque-upload upload ./README.md -t "项目说明"

# 上传到指定知识库
yuque-upload upload ./README.md -r zhangfan-9eaud/my-repo

# 批量上传
yuque-upload upload-batch ./docs

# 查看知识库列表
yuque-upload list-repos

# 查看知识库中的文档
yuque-upload list-docs zhangfan-9eaud/my-repo
```

## 配置

配置文件：`~/.config/yuque-upload/config.json`

```json
{
  "token": "your-api-token",
  "defaultRepo": "zhangfan-9eaud/my-repo",
  "userLogin": "zhangfan-9eaud",
  "userName": "张凡"
}
```

## 依赖

- bash
- curl
- python3

## 文档

详细使用指南：`docs/usage-guide.md`

## 许可

MIT License
