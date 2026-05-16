#!/bin/bash
# diy.sh - 编译完成前的自定义操作
# 主要任务：预下载 OpenClash 的 Meta/Mihomo 内核，避免路由器首次启动时因网络问题下载失败

set -e

echo ">>> [DIY] 开始自定义操作..."

# ===== 1. 预下载 Mihomo Meta 内核 =====
# OpenClash 会在 /etc/openclash/core/ 下查找内核
CORE_DIR="files/etc/openclash/core"
mkdir -p "$CORE_DIR"

echo ">>> [DIY] 下载 Mihomo Meta 内核 (arm64)..."

# 获取最新 release tag
MIHOMO_TAG=$(curl -sL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" \
  | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\(.*\)".*/\1/')

echo ">>> [DIY] Mihomo 最新版本: $MIHOMO_TAG"

# 下载 arm64 版本（Pi 4B 是 aarch64）
curl -sL "https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_TAG}/mihomo-linux-arm64-${MIHOMO_TAG}.gz" \
  -o /tmp/mihomo.gz

gzip -d /tmp/mihomo.gz
mv /tmp/mihomo "$CORE_DIR/clash_meta"
chmod +x "$CORE_DIR/clash_meta"

echo ">>> [DIY] Mihomo Meta 内核下载完成: $(ls -lh $CORE_DIR/clash_meta)"

# ===== 2. 预设 IP、主机名、主题 =====
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/98-basic-config.sh << 'EOF'
#!/bin/sh
# LAN IP 固定为 192.168.17.99
uci set network.lan.ipaddr='192.168.17.99'
uci set network.lan.gateway='192.168.17.1'
uci set network.lan.dns='192.168.17.1'
uci set network.lan.netmask='255.255.255.0'
# 主机名
uci set system.@system[0].hostname='Freedom'
# 时区
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
# 关掉 DHCP server（旁路由不抢）
uci set dhcp.lan.ignore='1'
# 设置 Argon 为默认主题
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit network
uci commit system
uci commit dhcp
uci commit luci
EOF
chmod +x files/etc/uci-defaults/98-basic-config.sh

# ===== 3. 关闭 IPv6（旁路由场景通常不需要，避免干扰）=====
cat > files/etc/uci-defaults/99-disable-ipv6.sh << 'EOF'
#!/bin/sh
# 旁路由场景禁用 IPv6，避免与主路由冲突
uci set network.lan.ipv6=0
uci set dhcp.lan.dhcpv6=disabled
uci set dhcp.lan.ra=disabled
uci commit network
uci commit dhcp
EOF
chmod +x files/etc/uci-defaults/99-disable-ipv6.sh

echo ">>> [DIY] 所有自定义操作完成"
