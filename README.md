# infraforge
linux生产与实验模板机自动化配置

## 概述

infraforge 是一个用于Rocky Linux的生产与实验模板机自动化配置的脚本集合。脚本采用叠加式设计，后置脚本会自动包含前置脚本的配置。

## 脚本依赖关系

```
base_template.sh (基础模板)
    ├── base_template-vmware.sh (VMware实验环境扩展)
    └── secure_template.sh (生产环境安全加固)
        ├── data_node.sh (数据库节点优化)
        ├── ingress_node.sh (入口节点优化)
        ├── master_node.sh (控制节点优化)
        ├── master_node-k8s.sh (Kubernetes控制节点优化)
        ├── worker_node.sh (计算节点优化)
        └── worker_node-k8s.sh (Kubernetes计算节点优化)
```

## 使用场景

### 1. 基础模板配置

#### 生产环境基础模板：
```bash
./base_template.sh
```

#### VMware实验环境基础模板：
```bash
./base_template-vmware.sh
```
*注意：`base_template-vmware.sh` 会自动包含 `base_template.sh`*

### 2. 安全加固配置

#### 生产环境安全加固：
```bash
./secure_template.sh
```

#### VMware实验环境安全加固：
```bash
VMWARE=1 ./secure_template.sh
```
或
```bash
export VMWARE=1
./secure_template.sh
```
- `secure_template.sh` → 根据 `VMWARE` 环境变量选择 `source ./base_template.sh` 或 `source ./base_template-vmware.sh`
### 3. 节点特定配置

所有节点脚本都会自动包含 `secure_template.sh` 和相应的基础模板。

#### 数据库节点：
```bash
./data_node.sh
```

#### 入口/代理节点：
```bash
./ingress_node.sh
```

#### 控制节点：
```bash
./master_node.sh
```

#### Kubernetes控制节点：
```bash
./master_node-k8s.sh
```

#### 计算节点：
```bash
./worker_node.sh
```

#### Kubernetes计算节点：
```bash
./worker_node-k8s.sh
```

## 重要注意事项

1. **关机命令**：所有节点脚本（`*_node.sh`）执行完成后会自动关机（`sudo shutdown -h now`）
2. **环境变量**：只有 `secure_template.sh` 需要使用 `VMWARE=1` 环境变量来区分基础模板
3. **执行顺序**：脚本采用 `source` 机制自动包含依赖，无需手动按顺序执行
4. **幂等性**：某些操作（如清空 machine-id、删除 SSH 密钥）在重复执行时可能会有影响

## 从 GitHub 远程执行

### 方法1：下载后执行
```bash
# 下载脚本
curl -O https://raw.githubusercontent.com/[用户名]/infraforge/main/data_node.sh

# 添加执行权限
chmod +x data_node.sh

# 执行脚本
./data_node.sh
```

### 方法2：使用 wget
```bash
# 下载并执行
wget -qO- https://raw.githubusercontent.com/[用户名]/infraforge/main/data_node.sh | sudo bash
```

## 脚本说明

### base_template.sh
- 基础系统配置
- 安装常用工具包
- 系统优化（SSH、limits、sysctl）
- 历史记录和提示符优化
- 系统清理

### base_template-vmware.sh
- 包含 `base_template.sh` 的所有功能
- 安装 VMware Tools

### secure_template.sh
- 根据 `VMWARE` 环境变量选择基础模板
- 禁用 root SSH 登录
- 修改 SSH 端口为 22222
- 配置防火墙

### 节点脚本
- 各自针对特定角色优化内核参数
- 自动包含安全加固和基础模板
- 执行完成后自动关机
