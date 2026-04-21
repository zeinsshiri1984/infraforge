#!/bin/bash
sudo dnf update -y
sudo dnf install -y \
  vim curl wget git \
  bash-completion bash-completion-extras \
  net-tools lsof iproute \
  chrony epel-release \
  tar tree jq rsync \
  sysstat tcpdump traceroute bind-utils \
  dnf-utils
  
# 启动关键服务并设置开机自启
sudo systemctl enable --now chronyd
# 时区
timedatectl set-timezone Asia/Singapore

# SSH 基础优化：减少登录时延迟
# sshd_config选项UseDNS关闭后可减少反向解析等待;无论是注释还是非注释状态都进行替换 
# GSSAPIAuthentication 如果不用 Kerberos/GSSAPI，可关闭
sudo sed -ri 's/^#?UseDNS .*/UseDNS no/' /etc/ssh/sshd_config
sudo sed -ri 's/^#?GSSAPIAuthentication .*/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 高并发优化: 不修改全局默认主配置; 用额外的叠加配置文件实现模板这一层意图
sudo tee /etc/security/limits.d/99-template.conf >/dev/null <<'EOF'
* soft nofile 65535
* hard nofile 65535
EOF
sudo tee /etc/sysctl.d/99-template.conf >/dev/null <<'EOF'
fs.file-max = 1000000
net.core.somaxconn = 65535
net.ipv4.ip_local_port_range = 10240 65535
EOF
sudo sysctl --system

# 确保集群每台节点 hostname、IP、machine-id、SSH key 都唯一
sudo hostnamectl set-hostname rocky-template
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo rm -f /etc/ssh/ssh_host_*

# history 优化
sudo tee /etc/profile.d/history.sh >/dev/null <<'EOF'
# 历史大小
export HISTSIZE=100000
export HISTFILESIZE=200000
# 时间戳
export HISTTIMEFORMAT="%F %T "
# 忽略重复命令和以空格开头的命令
export HISTCONTROL=ignoreboth
shopt -s histappend
# 记录命令并更新提示符状态
PROMPT_COMMAND='history -a; history -n'
EOF

# 安全别名
sudo tee /etc/profile.d/safe.sh >/dev/null <<'EOF'
# 防止误覆盖
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
# 显示颜色
alias ls='ls --color=auto'
EOF

# prompt优化
cat <<'EOF' > /etc/profile.d/ps1.sh
# 提取非 0 退出状态码
get_exit_status() {
    local exit_code=$?
    if[ $exit_code -ne 0 ]; then
        echo -e "[\e[1;31m✘ $exit_code\e[0m] "
    fi
}

# 格式: [时间] 用户@主机:当前路径[✘ 错误码] 
export PS1="\[\e[1;36m\][\t]\[\e[0m\] \[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\] \$(get_exit_status)\n\\$ "
EOF
# 确保所有 bash 都加载 profile.d
if ! grep -q profile.d /etc/bashrc; then
cat <<'EOF' | sudo tee -a /etc/bashrc >/dev/null

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    [ -r "$i" ] && . "$i"
  done
fi
EOF
fi

# 输入优化
sudo tee /etc/inputrc >/dev/null <<'EOF'
"\e[A": history-search-backward
"\e[B": history-search-forward
EOF

# 清除缓存
sudo dnf clean all
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
# 清除日志
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s
sudo rm -f /var/log/wtmp /var/log/btmp /var/log/lastlog
# 清除历史
cat /dev/null > ~/.bash_history
sudo history -c
sudo history -w

sudo shutdown -h now
