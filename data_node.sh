sudo tee /etc/sysctl.d/99-data.conf >/dev/null <<'EOF'
# 极大降低使用 Swap 的倾向，但不彻底关闭，防止内存泄漏直接 Kill 数据库进程
vm.swappiness = 10
# 控制脏页刷盘策略，平滑磁盘 I/O，防止 I/O 尖峰卡顿
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
# MySQL/MariaDB 异步 I/O (AIO) 所需
fs.aio-max-nr = 1048576
EOF

sudo sysctl --system

# 提升文件描述符，数据库连接池和底层文件句柄极多
sudo tee /etc/security/limits.d/99-data.conf >/dev/null <<'EOF'
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 65535
* hard nproc 65535
EOF
