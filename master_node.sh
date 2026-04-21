#!/bin/bash
# 内核参数
sudo tee /etc/sysctl.d/99-master.conf <<'EOF'
# (通用) 开启 IPv4 转发
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
