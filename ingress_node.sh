#!/bin/bash

source ./secure_template.sh

sudo tee /etc/sysctl.d/99-ingress.conf >/dev/null <<'EOF'
# 极大提升队列，应对突发高并发握手
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 262144
# 扩大可用本地端口范围，防止作为反向代理时耗尽端口
net.ipv4.ip_local_port_range = 10240 65535
# 允许复用 TIME-WAIT 状态的 sockets (应对压测和海量短连接)
net.ipv4.tcp_tw_reuse = 1
# 缩短 keepalive 探测时间，快速释放死链接
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
EOF

sudo sysctl --system

sudo shutdown -h now