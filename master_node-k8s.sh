#!/bin/bash

source ./secure_template.sh

# 关闭 swap（K8s）
sudo swapoff -a
sudo sed -ri '/swap/s/^/#/' /etc/fstab

# 内核参数
sudo tee /etc/sysctl.d/99-master.conf <<'EOF'
# (K8s) 允许 iptables 看到 bridge 流量
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
# (通用) 开启 IPv4 转发
net.ipv4.ip_forward = 1
EOF

# (K8s) 加载网桥过滤模块
sudo modprobe br_netfilter
echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf

sudo sysctl --system

sudo shutdown -h now
