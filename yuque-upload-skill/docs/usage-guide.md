# 语雀文档上传工具使用指南

一键将 Markdown 文档上传到语雀知识库。

## 功能特性

- 🔐 安全存储 API Token
- 📤 单文档上传
- 📦 批量文档上传
- 📚 知识库管理
- 📄 文档列表查看

---

## 安装

```bash
# 解压到 OpenClaw skills 目录
tar -xzf yuque-upload-skill-v1.0.0.tar.gz -C ~/.openclaw/skills/

# 添加执行权限
chmod +x ~/.openclaw/skills/yuque-upload-skill/scripts/*.sh
```

---

## 快速开始

### 1. 配置语雀 Token

```bash
yuque-upload setup
```

按照提示输入：
- 语雀 API Token（从 https://www.yuque.com/settings/tokens 获取）
- 选择默认知识库

### 2. 上传文档

**单文档上传：**
```bash
yuque-upload upload ./my-document.md
```

**指定标题和知识库：**
```bash
yuque-upload upload ./my-document.md -t "我的文档标题" -r zhangfan-9eaud/my-repo
```

**批量上传：**
```bash
yuque-upload upload-batch ./docs-directory
```

---

## 命令详解

### setup - 配置初始化

```bash
yuque-upload setup
```

功能：
- 配置语雀 API Token
- 选择默认知识库
- 保存用户配置

配置存储位置：`~/.config/yuque-upload/config.json`

---

### upload - 上传单文档

```bash
yuque-upload upload <markdown文件> [选项]
```

选项：
| 选项 | 说明 | 示例 |
|------|------|------|
| `-t, --title` | 指定文档标题 | `-t "我的文档"` |
| `-r, --repo` | 指定知识库 | `-r zhangfan-9eaud/my-repo` |
| `-s, --slug` | 指定文档 URL 别名 | `-s my-doc-slug` |

示例：
```bash
# 基本上传
yuque-upload upload ./README.md

# 指定标题
yuque-upload upload ./README.md -t "项目说明文档"

# 指定知识库
yuque-upload upload ./README.md -r zhangfan-9eaud/peuqzm

# 组合使用
yuque-upload upload ./guide.md -t "用户指南" -r zhangfan-9eaud/docs -s user-guide
```

---

### upload-batch - 批量上传

```bash
yuque-upload upload-batch <目录> [选项]
```

选项：
| 选项 | 说明 | 示例 |
|------|------|------|
| `-r, --repo` | 指定知识库 | `-r zhangfan-9eaud/my-repo` |
| `--dry-run` | 模拟运行，不实际上传 | `--dry-run` |

示例：
```bash
# 批量上传目录下所有 markdown 文件
yuque-upload upload-batch ./docs

# 指定知识库
yuque-upload upload-batch ./docs -r zhangfan-9eaud/peuqzm

# 模拟运行（测试用）
yuque-upload upload-batch ./docs --dry-run
```

---

### list-repos - 列出知识库

```bash
yuque-upload list-repos
```

显示当前用户的所有知识库列表。

---

### list-docs - 列出文档

```bash
yuque-upload list-docs <repo>
```

示例：
```bash
yuque-upload list-docs zhangfan-9eaud/peuqzm
```

---

## 配置说明

### 配置文件位置

`~/.config/yuque-upload/config.json`

### 配置格式

```json
{
  "token": "your-api-token",
  "defaultRepo": "zhangfan-9eaud/my-repo",
  "userLogin": "zhangfan-9eaud",
  "userName": "张凡",
  "createdAt": "2026-03-22T12:00:00Z"
}
```

### 手动修改配置

```bash
# 编辑配置文件
nano ~/.config/yuque-upload/config.json

# 或者重新运行 setup
yuque-upload setup
```

---

## 获取语雀 API Token

1. 登录语雀：https://www.yuque.com
2. 点击右上角头像 → 设置
3. 选择左侧菜单 "Token"
4. 点击 "新建 Token"
5. 输入名称（如：文档上传工具）
6. 复制生成的 Token

注意：Token 只显示一次，请妥善保存。

---

## 常见问题

### Q1: Token 验证失败

**原因：**
- Token 输入错误
- Token 已过期或被删除

**解决：**
```bash
# 重新配置 Token
yuque-upload setup
```

### Q2: 知识库找不到

**原因：**
- 知识库命名空间错误
- 没有该知识库的写入权限

**解决：**
```bash
# 查看可用的知识库
yuque-upload list-repos
```

### Q3: 上传失败，文档已存在

**原因：**
- 相同 slug 的文档已存在

**解决：**
- 使用不同的标题（会自动生成不同的 slug）
- 手动指定 slug：`-s unique-slug`

### Q4: 批量上传部分失败

**解决：**
- 使用 `--dry-run` 测试
- 检查失败的错误信息
- 单独上传失败的文件

---

## 使用示例

### 场景 1：上传项目文档

```bash
# 配置
yuque-upload setup

# 上传 README
yuque-upload upload ./README.md -t "项目介绍"

# 上传开发文档目录
yuque-upload upload-batch ./docs/dev -r zhangfan-9eaud/dev-docs

# 上传用户文档目录
yuque-upload upload-batch ./docs/user -r zhangfan-9eaud/user-docs
```

### 场景 2：自动化文档发布

```bash
#!/bin/bash
# deploy-docs.sh

# 构建文档
npm run build:docs

# 上传到语雀
yuque-upload upload-batch ./dist/docs -r zhangfan-9eaud/project-docs

echo "文档发布完成！"
```

---

## 文件结构

```
yuque-upload-skill/
├── skill.json              # Skill 配置
├── README.md               # 说明文档
├── scripts/
│   ├── setup.sh            # 配置初始化
│   ├── upload.sh           # 单文档上传
│   ├── upload-batch.sh     # 批量上传
│   ├── list-repos.sh       # 列出知识库
│   └── list-docs.sh        # 列出文档
└── docs/
    └── usage-guide.md      # 本使用指南
```

---

## 更新日志

### v1.0.0 (2026-03-22)

- 初始版本发布
- 支持 Token 配置
- 支持单文档上传
- 支持批量文档上传
- 支持知识库列表查看
- 支持文档列表查看

---

## 许可证

MIT License

---

## 相关链接

- [语雀 API 文档](https://www.yuque.com/yuque/developer)
- [获取 API Token](https://www.yuque.com/settings/tokens)
