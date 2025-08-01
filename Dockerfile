FROM ubuntu:22.04

# 设置时区和语言环境
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=C.UTF-8

# 安装基础工具和依赖
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 安装 Amazon Q CLI (ARM64)
RUN curl --proto '=https' --tlsv1.2 -sSf \
    "https://desktop-release.q.us-east-1.amazonaws.com/latest/q-aarch64-linux.zip" \
    -o /tmp/q.zip \
    && unzip /tmp/q.zip -d /tmp/q \
    && /tmp/q/install.sh --no-confirm \
    && rm -rf /tmp/q.zip /tmp/q

# 安装 AWS CLI v2 (ARM64)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "/tmp/awscliv2.zip" \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# 创建必要的配置目录
RUN mkdir -p /root/.aws/amazonq \
    && mkdir -p /workspace/.amazonq

# 设置工作目录
WORKDIR /workspace

# 设置环境变量
ENV Q_LOG_LEVEL=info
ENV PATH="/root/.local/bin:/usr/local/bin:${PATH}"

# 设置默认命令
CMD ["/bin/bash"]