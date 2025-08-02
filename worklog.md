# 工作日志

## 2025-08-01T12:30 Amazon Q CLI 跨平台认证信息迁移解决方案

### 问题描述
在将 Amazon Q CLI 容器化时发现，macOS 和 Linux 系统的认证信息存储机制不同：
- **macOS**: 使用 macOS Keychain 存储认证令牌，无法直接迁移文件
- **Linux**: 使用文件系统存储在 `/home/quser/.local/share/amazon-q` 目录

### 解决方案

#### 1. 认证信息获取流程

**步骤1：在容器内完成登录**
```bash
# 启动临时容器
docker run --platform linux/arm64 -it --rm \
  -v /tmp/q-temp-auth:/home/quser/.local/share/amazon-q \
  ghcr.io/kun-g/q:latest bash

# 在容器内登录
q login --license free
# 按提示完成浏览器认证流程

# 验证登录成功
q whoami
```
q login -h
Login

Usage: q login [OPTIONS]

Options:
      --license <LICENSE>
          License type (pro for Identity Center, free for Builder ID) [possible values: free, pro]
      --identity-provider <IDENTITY_PROVIDER>
          Identity provider URL (for Identity Center)
      --region <REGION>
          Region (for Identity Center)
      --use-device-flow
          Always use the OAuth device flow for authentication. Useful for instances where browser
          redirects cannot be handled
  -v, --verbose...
          Increase logging verbosity
  -h, --help
          Print help (see more with '--help')

**步骤2：提取认证信息**
```bash
# 方法A：从运行中的容器复制
docker cp <container_id>:/home/quser/.local/share/amazon-q /path/to/save/

# 方法B：使用挂载目录（推荐）
# 在步骤1中直接挂载持久化目录，登录后自动保存
```
这里可以用q whoami 命令获取Id来给文件夹命名

**步骤3：验证认证信息**
```bash
# 测试提取的认证信息是否有效
docker run --platform linux/arm64 --rm \
  -v /path/to/saved/amazon-q:/home/quser/.local/share/amazon-q \
  ghcr.io/kun-g/q:latest q doctor
```

#### 2. 多账号管理

**目录结构建议：**
```
/data/workdir/q-config/
├── ACCOUNT_ID_1/           # 第一个账号的认证信息
│   └── amazon-q/
├── ACCOUNT_ID_2/           # 第二个账号的认证信息
│   └── amazon-q/
└── ACCOUNT_ID_3/           # 第三个账号的认证信息
    └── amazon-q/
```

**使用不同账号：**
```bash
# 账号1
docker run --platform linux/arm64 -it --rm \
  -v /data/workdir/q-config/ACCOUNT_ID_1:/home/quser/.local/share/amazon-q \
  -v $(pwd):/home/quser/workspace \
  ghcr.io/kun-g/q:latest bash

# 账号2  
docker run --platform linux/arm64 -it --rm \
  -v /data/workdir/q-config/ACCOUNT_ID_2:/home/quser/.local/share/amazon-q \
  -v $(pwd):/home/quser/workspace \
  ghcr.io/kun-g/q:latest bash
```

#### 3. 自动化脚本

**创建新账号认证信息：**
```bash
#!/bin/bash
ACCOUNT_ID=$1
AUTH_DIR="/data/workdir/q-config/${ACCOUNT_ID}"

echo "为账号 ${ACCOUNT_ID} 设置 Amazon Q 认证..."

# 创建认证目录
mkdir -p "${AUTH_DIR}"

# 启动容器进行登录
docker run --platform linux/arm64 -it --rm \
  -v "${AUTH_DIR}:/home/quser/.local/share/amazon-q" \
  ghcr.io/kun-g/q:latest bash -c "
    echo '请在容器内运行: q login --license free'
    echo '完成登录后输入: q whoami 验证'
    bash
  "

echo "认证信息已保存到: ${AUTH_DIR}"
```

**使用已有认证信息：**
```bash
#!/bin/bash
ACCOUNT_ID=$1
AUTH_DIR="/data/workdir/q-config/${ACCOUNT_ID}"

if [ ! -d "${AUTH_DIR}" ]; then
    echo "错误：账号 ${ACCOUNT_ID} 的认证信息不存在"
    exit 1
fi

docker run --platform linux/arm64 -it --rm \
  -v "${AUTH_DIR}:/home/quser/.local/share/amazon-q" \
  -v "$(pwd):/home/quser/workspace" \
  ghcr.io/kun-g/q:latest bash
```

### 经验总结

1. **平台差异**: macOS 的 Keychain 机制导致认证信息无法直接文件迁移
2. **Linux 路径**: Amazon Q CLI 在 Linux 下的认证信息存储在 `~/.local/share/amazon-q`
3. **容器隔离**: 每个账号的认证信息完全隔离，避免冲突
4. **持久化存储**: 使用 Docker volume 挂载确保认证信息持久化
5. **验证重要**: 每次提取后都要验证认证信息的有效性

### 注意事项

- 认证信息包含敏感数据，需要适当的文件权限保护
- 定期检查认证信息的有效期，Amazon Q 的令牌可能会过期
- 在 CI/CD 环境中使用时，考虑使用密钥管理服务而不是文件存储

### 后续优化

可以考虑将认证信息集成到容器的环境变量或密钥管理系统中，进一步提升安全性和易用性。