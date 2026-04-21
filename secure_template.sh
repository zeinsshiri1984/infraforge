#!/bin/bash
# 修改SSH配置，禁止root直接远程登录
sudo sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
# 修改SSH配置文件中Port 22 替换为 Port 22222; 避开端口扫描（云服务器需同步安全组）
sudo sed -ri 's/^#?Port .*/Port 22222/' /etc/ssh/sshd_config
# 防火墙放行 22222 端口
sudo firewall-cmd --permanent --zone=public --add-port=22222/tcp
# 重新加载防火墙配置使其生效
sudo firewall-cmd --reload
# 重启 sshd 服务
sudo systemctl restart sshd
