FROM ghcr.io/getimages/xray:latest

# 复制配置文件
COPY config.json /etc/xray/config.json

# 暴露端口
EXPOSE 8080

# 启动命令
CMD ["xray", "-config", "/etc/xray/config.json"]
