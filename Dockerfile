# 使用官方Alpine Linux作为基础镜像
FROM alpine:3.18

# 设置维护者信息
LABEL maintainer="你的邮箱"
LABEL description="Custom VLESS proxy server with Xray-core"
LABEL version="1.0"

# 设置工作目录
WORKDIR /app

# 安装必要的软件包
RUN apk add --no-cache \
    curl \
    unzip \
    ca-certificates \
    tzdata \
    bash \
    && rm -rf /var/cache/apk/*

# 设置时区
ENV TZ=UTC

# 创建应用用户（安全考虑）
RUN addgroup -g 1000 xray && \
    adduser -u 1000 -G xray -s /bin/sh -D xray

# 创建必要目录
RUN mkdir -p /etc/xray /usr/local/bin /var/log/xray /tmp && \
    chown -R xray:xray /etc/xray /var/log/xray /tmp

# 下载最新版Xray-core
RUN XRAY_VERSION=$(curl -s "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    echo "Downloading Xray version: $XRAY_VERSION" && \
    curl -L -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" && \
    unzip /tmp/xray.zip -d /tmp && \
    mv /tmp/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    /usr/local/bin/xray version && \
    rm -rf /tmp/*

# 复制配置文件和脚本
COPY --chown=xray:xray config.json /etc/xray/config.json.template
COPY --chown=xray:xray entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=xray:xray health-check.sh /usr/local/bin/health-check.sh

# 设置脚本权限
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/health-check.sh

# 切换到非root用户
USER xray

# 暴露端口
EXPOSE 8080

# 设置环境变量默认值
ENV UUID="" \
    VLESS_PATH="/vless" \
    VMESS_PATH="/vmess" \
    LOG_LEVEL="warning"

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# 启动命令
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
