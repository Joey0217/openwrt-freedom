#!/bin/bash
# diy.sh - 仅做基础配置，不下载任何第三方内容

set -e

echo ">>> [DIY] 开始基础配置..."

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/98-basic-config.sh << 'EOF'
#!/bin/sh

# LAN IP
uci set network.lan.ipaddr='192.168.17.99'
uci set network.lan.gateway='192.168.17.1'
uci set network.lan.dns='192.168.17.1'
uci set network.lan.netmask='255.255.255.0'

# 主机名
uci set system.@system[0].hostname='Freedom'

# 时区
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'

# 关掉 DHCP（旁路由不抢）
uci set dhcp.lan.ignore='1'

# 禁用 IPv6
uci set network.lan.ipv6=0
uci set dhcp.lan.dhcpv6=disabled
uci set dhcp.lan.ra=disabled

uci commit network
uci commit system
uci commit dhcp

EOF

chmod +x files/etc/uci-defaults/98-basic-config.sh

echo ">>> [DIY] 完成"
