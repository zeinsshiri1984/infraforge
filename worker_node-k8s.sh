#!/bin/bash

source ./secure_template.sh

# (K8s) 关闭 swap，K8s kubelet 默认要求; 如果是跑普通 Java/Go 进程的物理机，建议保留 Swap（配置很低的 swappiness），防止突发 OOM。K8s 节点则关闭
sudo swapoff -a
sudo sed -ri '/swap/s/^/#/' /etc/fstab

sudo tee /etc/sysctl.d/99-worker.conf >/dev/null <<'EOF'
# (通用高并发) 提升半连接队列和全连接队列上限
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
# (通用) 提升 mmap 限制，Elasticsearch/SonarQube/Kafka 等 JVM/大数据应用必备
vm.max_map_count = 262144
EOF

sudo sysctl --system

sudo shutdown -h now