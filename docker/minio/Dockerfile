FROM minio/minio:latest

# 如果需要自定义配置，可以在这里添加
# COPY custom-config.json /root/.minio/config.json

CMD ["server", "/data", "--console-address", ":9001"]