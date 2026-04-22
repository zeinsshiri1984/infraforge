#!/bin/bash

source ./secure_template.sh

sudo tee /etc/sysctl.d/99-worker.conf >/dev/null <<'EOF'
# (通用高并发) 提升半连接队列和全连接队列上限
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
# (通用) 提升 mmap 限制，Elasticsearch/SonarQube/Kafka 等 JVM/大数据应用必备
vm.max_map_count = 262144
# (物理机防 OOM 补充) 只有在未关闭 swap 的物理机上才生效，尽量避免使用 swap
vm.swappiness = 10
EOF

sudo sysctl --system

sudo shutdown -h now