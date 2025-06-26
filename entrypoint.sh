#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# 生成UUID如果没有提供
if [ -z "$UUID" ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)
    warn "UUID not provided, generated: $UUID"
fi

# 验证UUID格式
if ! echo "$UUID" | grep -qE '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'; then
    error "Invalid UUID format: $UUID"
    exit 1
fi

# 设置默认值
VLESS_PATH=${VLESS_PATH:-/vless}
VMESS_PATH=${VMESS_PATH:-/vmess}
LOG_LEVEL=${LOG_LEVEL:-warning}

# 验证路径格式
if [[ ! "$VLESS_PATH" =~ ^/ ]]; then
    VLESS_PATH="/$VLESS_PATH"
fi
if [[ ! "$VMESS_PATH" =~ ^/ ]]; then
    VMESS_PATH="/$VMESS_PATH"
fi

# 创建配置文件
log "Generating Xray configuration..."
cp /etc/xray/config.json.template /etc/xray/config.json

# 替换配置文件中的变量
sed -i "s|\${UUID}|${UUID}|g" /etc/xray/config.json
sed -i "s|\${VLESS_PATH}|${VLESS_PATH}|g" /etc/xray/config.json
sed -i "s|\${VMESS_PATH}|${VMESS_PATH}|g" /etc/xray/config.json
sed -i "s|\${LOG_LEVEL}|${LOG_LEVEL}|g" /etc/xray/config.json

# 验证配置文件
log "Validating configuration..."
if ! /usr/local/bin/xray test -config /etc/xray/config.json; then
    error "Configuration validation failed!"
    exit 1
fi

# 显示配置信息
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}  🚀 VLESS Server Starting...${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}UUID:${NC}        $UUID"
echo -e "${GREEN}VLESS Path:${NC}  $VLESS_PATH"
echo -e "${GREEN}VMESS Path:${NC}  $VMESS_PATH"
echo -e "${GREEN}Log Level:${NC}   $LOG_LEVEL"
echo -e "${GREEN}Time:${NC}        $(date)"
echo -e "${GREEN}Version:${NC}     $(/usr/local/bin/xray version | head -n1)"
echo -e "${BLUE}=========================================${NC}"

# 启动Xray
log "Starting Xray server..."
exec /usr/local/bin/xray run -config /etc/xray/config.json
