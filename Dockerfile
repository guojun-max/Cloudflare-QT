# 使用轻量级 Debian 基础镜像
FROM debian:bookworm-slim

# 设置工作目录
WORKDIR /app
# 1. 换源（阿里云）
RUN sed -i 's|http://deb.debian.org|http://mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources \
    && sed -i 's|http://security.debian.org|http://mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list.d/debian.sources

# 2. 安装 curl 和 ca-certificates（curl 是下载 cloudflared 所必需的）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 将预先下载好的二进制文件复制到镜像中
# 请确保 cf-quicktunnel-linux-amd64 文件与 Dockerfile 在同一目录下
#COPY cf-quicktunnel-linux-amd64 /app/cf-quicktunnel
RUN mkdir -p /app/bin \
    && curl -L -o /app/bin/cloudflared \
      https://gh-proxy.com/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /app/bin/cloudflared

RUN curl -L -o /app/cf-quicktunnel \
      https://gh-proxy.com/https://github.com/IMGZCQ/Cloudflare-QT/releases/latest/download/cf-quicktunnel-linux-amd64 \
    && chmod +x /app/cf-quicktunnel
# 赋予执行权限
#RUN chmod +x /app/cf-quicktunnel

# 创建持久化数据目录，用于保存隧道配置
# 对应文档中的 CFQT_DATA_DIR 环境变量
RUN mkdir -p /app/data

# 设置环境变量
# 1. 监听所有地址，以便 Docker 端口映射后能从宿主机访问
# 2. 将数据目录指向 /app/data，方便挂载卷进行持久化
ENV CFQT_ADDR=0.0.0.0:9970
ENV CFQT_DATA_DIR=/app/data

# 暴露管理界面端口
EXPOSE 9970

# 启动程序
CMD ["/app/cf-quicktunnel"]
