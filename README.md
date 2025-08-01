# Amazon Q CLI Docker Base Image

这是一个包含 Amazon Q CLI 和相关工具的 Docker 基础镜像，可以作为其他应用的基座使用。

## 包含的工具

- Amazon Q CLI
- AWS CLI v2
- Git
- Python3 & pip
- curl, jq, vim 等常用工具

## 使用方法

### 1. 本地认证

首先在你的 Mac 系统上完成 Amazon Q 登录：

```bash
q login --license free
```

### 2. 运行容器

挂载认证目录到容器中：

```bash
# 基础用法
docker run -it --rm \
  -v ~/.aws:/root/.aws \
  -v $(pwd):/workspace \
  ghcr.io/你的用户名/q:latest

# 交互式使用
docker run -it --rm \
  -v ~/.aws:/root/.aws \
  -v $(pwd):/workspace \
  ghcr.io/你的用户名/q:latest bash
```

### 3. 验证安装

在容器内验证 Amazon Q CLI 是否正常工作：

```bash
q doctor
q --version
aws --version
```

## 目录结构

- `/root/.aws/amazonq/` - Amazon Q 全局配置目录
- `/workspace/.amazonq/` - 工作空间配置目录
- `/workspace` - 默认工作目录

## 环境变量

- `Q_LOG_LEVEL=info` - Amazon Q 日志级别
- `TZ=UTC` - 时区设置
- `LANG=C.UTF-8` - 语言环境

## 构建信息

- 基础镜像：Ubuntu 22.04
- 支持架构：linux/amd64, linux/arm64
- 自动构建：通过 GitHub Actions 触发

## 扩展使用

可以基于此镜像构建包含特定功能的派生镜像：

```dockerfile
FROM ghcr.io/你的用户名/q:latest

# 安装额外的工具和依赖
RUN apt-get update && apt-get install -y 你的工具

# 复制你的脚本
COPY scripts/ /usr/local/bin/

# 设置入口点
CMD ["你的命令"]
```