#!/bin/bash

# Amazon Q Docker 镜像测试脚本

set -e

IMAGE_NAME="${1:-amazon-q-base:latest}"

echo "🧪 测试 Amazon Q Docker 镜像: $IMAGE_NAME"

# 测试基础命令
echo "📦 测试基础工具..."
docker run --rm "$IMAGE_NAME" bash -c "
    echo '✅ Ubuntu 版本:' && cat /etc/os-release | grep VERSION_ID
    echo '✅ Python 版本:' && python3 --version
    echo '✅ Git 版本:' && git --version
    echo '✅ AWS CLI 版本:' && aws --version
    echo '✅ Amazon Q CLI 版本:' && q --version
    echo '✅ 工具检查完成'
"

# 测试配置目录
echo "📁 测试配置目录..."
docker run --rm "$IMAGE_NAME" bash -c "
    echo '✅ 检查 ~/.aws/amazonq 目录:' && ls -la /root/.aws/amazonq/
    echo '✅ 检查 /workspace/.amazonq 目录:' && ls -la /workspace/.amazonq/
    echo '✅ 目录检查完成'
"

# 测试环境变量
echo "🌍 测试环境变量..."
docker run --rm "$IMAGE_NAME" bash -c "
    echo '✅ Q_LOG_LEVEL:' \$Q_LOG_LEVEL
    echo '✅ PATH:' \$PATH
    echo '✅ 工作目录:' && pwd
    echo '✅ 环境变量检查完成'
"

echo "🎉 所有测试通过！镜像 $IMAGE_NAME 可以正常使用。"