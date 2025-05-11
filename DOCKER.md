# MiniMax-MCP Docker 部署指南

本文档提供了使用 Docker 部署 MiniMax-MCP 服务的详细说明。

## 前提条件

- 安装 [Docker](https://www.docker.com/get-started)
- 安装 [Docker Compose](https://docs.docker.com/compose/install/)
- 获取 MiniMax API 密钥

## 快速开始

### 1. 配置环境变量

复制环境变量模板文件并进行配置：

```bash
cp .env.docker .env
```

编辑 `.env` 文件，填入您的 API 密钥和其他配置：

```
MINIMAX_API_KEY=your_api_key_here
MINIMAX_API_HOST=https://api.minimax.chat  # 国内版
# MINIMAX_API_HOST=https://api.minimaxi.chat  # 国际版（注意额外的"i"）
MINIMAX_API_RESOURCE_MODE=url  # 或 local
```

⚠️ **注意**：API 密钥需要与 API 主机地址匹配。如果出现 "API Error: invalid api key" 错误，请检查您的 API 主机地址是否正确。

### 2. 创建必要的目录

```bash
mkdir -p data config
```

### 3. 构建并启动容器

```bash
docker-compose up -d
```

这将构建 Docker 镜像并在后台启动容器。

### 4. 查看日志

```bash
docker-compose logs -f
```

## 配置 Claude Desktop

在 Claude Desktop 中配置 MCP 服务器：

1. 前往 `Claude > Settings > Developer > Edit Config > claude_desktop_config.json`
2. 添加以下配置（替换 `your-docker-host-ip` 为您的 Docker 主机 IP 地址）：

```json
{
  "mcpServers": {
    "MiniMax": {
      "url": "http://your-docker-host-ip:8080"
    }
  }
}
```

## 自定义配置

### 更改端口

如果需要更改端口，编辑 `docker-compose.yml` 文件中的 `ports` 部分：

```yaml
ports:
  - "8888:8080"  # 将主机端口从 8080 更改为 8888
```

### 数据持久化

默认情况下，数据存储在项目目录下的 `data` 文件夹中。如果需要更改数据存储位置，编辑 `docker-compose.yml` 文件中的 `volumes` 部分：

```yaml
volumes:
  - /path/to/your/data:/data
  - /path/to/your/config:/config
```

## 常见问题

### API 密钥错误

如果遇到 API 密钥错误，请确保：

1. API 密钥正确无误
2. API 主机地址与您的 API 密钥区域匹配：
   - 国际版：`https://api.minimaxi.chat`（注意额外的 "i"）
   - 国内版：`https://api.minimax.chat`

### 容器无法启动

检查容器日志：

```bash
docker-compose logs
```

### 重新构建镜像

如果更新了代码或配置，需要重新构建镜像：

```bash
docker-compose build --no-cache
docker-compose up -d
```

## 卸载

停止并删除容器：

```bash
docker-compose down
```

如果需要同时删除构建的镜像：

```bash
docker-compose down --rmi local
```