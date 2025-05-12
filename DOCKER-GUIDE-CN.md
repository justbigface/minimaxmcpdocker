# MiniMax-MCP Docker 部署指南

## 问题解决

在使用 Docker 部署 MiniMax-MCP 时，您可能会遇到以下问题：

1. 无法从官方 Docker Hub 拉取镜像
2. SSL 连接问题导致依赖安装失败
3. 环境变量配置不正确

本指南将帮助您解决这些问题。

## 已优化的配置

我们已经对以下文件进行了优化：

1. `Dockerfile` - 使用华为云镜像源替代官方源，优化了 pip 安装参数
2. `docker-compose.yml` - 修改环境变量配置，支持自定义 MCP 基础路径
3. `.env.docker` - 添加了 MCP 基础路径配置

## 部署步骤

### 1. 准备环境变量

复制 `.env.docker` 文件为 `.env`：

```bash
cp .env.docker .env
```

编辑 `.env` 文件，设置您的 API 密钥和其他配置：

```
# MiniMax MCP API配置
# 请替换为您的API密钥
MINIMAX_API_KEY=your_api_key_here

# API主机地址
# 国际版: https://api.minimaxi.chat (注意额外的"i")
# 国内版: https://api.minimax.chat
MINIMAX_API_HOST=https://api.minimax.chat

# 资源模式: url或local
MINIMAX_API_RESOURCE_MODE=url

# MCP基础路径
# 默认为容器内的/data目录，如需使用本地路径，请修改为绝对路径
MINIMAX_MCP_BASE_PATH=/data
```

**注意**：确保 API 密钥和 API 主机地址匹配同一区域（国内/国际）。

### 2. 构建和启动容器

使用以下命令构建并启动容器：

```bash
docker-compose build --no-cache
docker-compose up -d
```

如果仍然遇到网络问题，可以尝试以下方法：

1. 使用代理或 VPN 改善网络连接
2. 增加 Docker 构建超时时间：

```bash
docker-compose build --no-cache --build-arg DOCKER_CLIENT_TIMEOUT=600 --build-arg COMPOSE_HTTP_TIMEOUT=600
```

### 3. 检查容器状态

```bash
docker-compose ps
docker logs minimax-mcp
```

## 常见问题

### 1. 无法连接到 Docker Hub

错误信息：`failed to authorize: failed to fetch anonymous token`

解决方案：
- 我们已经将基础镜像更改为华为云镜像源
- 如果仍有问题，请检查您的网络连接或使用代理

### 2. SSL 连接问题

错误信息：`SSLError (SSLEOFError(8, '[SSL: UNEXPECTED_EOF_WHILE_READING] EOF occurred in violation of protocol (_ssl.c:1006)'))`

解决方案：
- 我们已经优化了 pip 安装参数，增加了超时时间和重试次数
- 如果仍有问题，请尝试在网络稳定的环境下构建

### 3. 环境变量问题

确保您的 `.env` 文件中的环境变量正确设置，特别是：

- `MINIMAX_API_KEY` - 必须与 API 主机地址匹配同一区域
- `MINIMAX_API_HOST` - 国内版为 `https://api.minimax.chat`，国际版为 `https://api.minimaxi.chat`
- `MINIMAX_MCP_BASE_PATH` - 如需使用本地路径，请设置为绝对路径

## 其他建议

如果您需要在本地使用特定路径作为 MCP 基础路径，请修改 `.env` 文件中的 `MINIMAX_MCP_BASE_PATH` 变量，并确保该路径在主机上存在且有适当的权限。

```
MINIMAX_MCP_BASE_PATH=C:\Users\Administrator\Documents\jiaoben\MiniMax-MCPdocker
```

然后，您需要在 `docker-compose.yml` 文件中添加相应的卷映射：

```yaml
volumes:
  - ${MINIMAX_MCP_BASE_PATH}:/data
  - ./config:/config
```

这样，容器内的 `/data` 目录将映射到您指定的本地路径。