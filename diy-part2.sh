#!/bin/bash

# 1. 修改后台默认 IP 为 192.168.112.200
sed -i 's/192.168.1.1/192.168.112.200/g' package/base-files/files/bin/config_generate

# 2. 旁路由配置：自动网关/DNS，关闭 LAN 口 DHCP
cat << 'EOF' >> package/base-files/files/etc/uci-defaults/99-custom-network
uci set network.lan.gateway='192.168.112.1'
uci del network.lan.dns
uci add_list network.lan.dns='192.168.112.1'
uci set dhcp.lan.ignore='1'
uci commit network
uci commit dhcp
EOF

# 3. 精准移除导致内核卡死的摄像头坏补丁
find target/linux/ -name "*810-uvc-add-iPassion-iP2970-support.patch*" -exec rm -rf {} \;

# 4. 解决 Go 工具链版本匹配问题
export GOTOOLCHAIN=auto

# 5. 拉取第三方整合插件源
git clone --depth=1 https://github.com/kenzok8/small-package.git package/small-package

# 6. 删除 small-package 里与官方冲突的 nftables 源码包
rm -rf package/small-package/nftables
