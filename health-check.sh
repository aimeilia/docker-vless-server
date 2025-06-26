#!/bin/bash

# 健康检查脚本
CHECK_URL="http://localhost:8080"

# 检查端口是否监听
if ! netstat -tuln 2>/dev/null | grep -q ":8080 "; then
    echo "Port 8080 is not listening"
    exit 1
fi

# 检查进程是否运行
if ! pgrep -f "xray" > /dev/null; then
    echo "Xray process not found"
    exit 1
fi

echo "Health check passed"
exit 0
