FROM python:3.11-slim

WORKDIR /app

# 安装依赖
COPY pyproject.toml setup.py ./
COPY minimax_mcp ./minimax_mcp/

# 安装项目
RUN pip install --no-cache-dir .

# 创建配置目录
RUN mkdir -p /config

# 设置环境变量
ENV MINIMAX_API_KEY=""
ENV MINIMAX_MCP_BASE_PATH="/data"
ENV MINIMAX_API_HOST="https://api.minimax.chat"
ENV MINIMAX_API_RESOURCE_MODE="url"

# 创建数据目录
RUN mkdir -p /data
VOLUME ["/data", "/config"]

# 暴露端口
EXPOSE 8080

# 启动服务
CMD ["uvicorn", "minimax_mcp.server:app", "--host", "0.0.0.0", "--port", "8080"]