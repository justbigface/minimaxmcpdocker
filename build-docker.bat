@echo off
echo ===== MiniMax-MCP Docker 构建脚本 =====
echo.

echo 1. 检查环境变量文件...
if not exist .env (
    echo 未找到.env文件，将复制.env.docker作为模板
    copy .env.docker .env
    echo 请编辑.env文件，设置您的API密钥和其他配置
    echo 按任意键继续...
    pause > nul
)

echo 2. 设置Docker构建超时参数...
set DOCKER_CLIENT_TIMEOUT=600
set COMPOSE_HTTP_TIMEOUT=600

echo 3. 清理并重新构建Docker镜像...
docker-compose build --no-cache

echo 4. 启动Docker容器...
docker-compose up -d

echo 5. 检查容器状态...
docker-compose ps

echo.
echo 如果容器未正常启动，请查看日志：
echo docker logs minimax-mcp
echo.
echo 详细指南请参考 DOCKER-GUIDE-CN.md
echo.

pause