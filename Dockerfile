FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/python:3.11-slim

WORKDIR /app

# 更新系统并安装必要工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 更新pip并设置缓存目录
RUN pip install --upgrade pip setuptools wheel

# 安装依赖
COPY pyproject.toml setup.py ./
COPY minimax_mcp ./minimax_mcp/

# 设置pip配置，使用稳定的国内镜像源和优化连接参数
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip config set global.trusted-host "mirrors.aliyun.com" \
    && pip config set global.timeout 300 \
    && pip config set global.retries 15 \
    && pip config set global.default-timeout 300 \
    && pip config set install.prefer-binary true \
    && pip config set global.no-cache-dir true

# 清理pip缓存
RUN pip cache purge

# 先安装基础工具，确保安装环境正常
RUN pip install --no-cache-dir --timeout 300 --retries 15 setuptools wheel \
    || (sleep 5 && pip install --no-cache-dir --timeout 300 --retries 15 -i https://pypi.tuna.tsinghua.edu.cn/simple/ setuptools wheel)

# 分批安装关键依赖，提高成功率
RUN pip install --no-cache-dir --timeout 300 --retries 15 pydantic \
    || (sleep 5 && pip install --no-cache-dir --timeout 300 --retries 15 -i https://pypi.tuna.tsinghua.edu.cn/simple/ pydantic)

RUN pip install --no-cache-dir --timeout 300 --retries 15 fastapi uvicorn httpx \
    || (sleep 5 && pip install --no-cache-dir --timeout 300 --retries 15 -i https://pypi.tuna.tsinghua.edu.cn/simple/ fastapi uvicorn httpx)

# 安装项目，使用更稳定的安装策略
RUN pip install --no-cache-dir --timeout 300 --retries 15 . \
    || (sleep 10 && pip install --no-cache-dir --timeout 300 --retries 15 -i https://pypi.tuna.tsinghua.edu.cn/simple/ .) \
    || (sleep 10 && pip install --no-cache-dir --timeout 300 --retries 15 -i https://mirrors.aliyun.com/pypi/simple/ .) \
    || (sleep 10 && pip install --no-cache-dir --timeout 300 --retries 15 --no-deps .)

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