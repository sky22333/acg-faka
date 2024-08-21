FROM webdevops/php-nginx:8.1-alpine

WORKDIR /app
COPY . .

RUN composer install --no-dev --optimize-autoloader

ENV MYSQL_HOST=localhost \
    MYSQL_USER=root \
    MYSQL_PASSWORD=password \
    MYSQL_DATABASE=your_database_name \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    OPCACHE_FILE_CACHE_DIR=/app/opcache_cache_dir \
    PHP_INI_FILE=/opt/docker/etc/php/php.ini \
    TIMEZONE="Asia/Shanghai"

# 配置 OPcache
RUN mkdir -p "$OPCACHE_FILE_CACHE_DIR" && \
    chown -R application:application "$OPCACHE_FILE_CACHE_DIR" && \
    { \
    echo "[opcache]"; \
    echo "opcache.enable=1"; \
    echo "opcache.memory_consumption=256"; \
    echo "opcache.interned_strings_buffer=16"; \
    echo "opcache.max_accelerated_files=5000"; \
    echo "opcache.revalidate_freq=5"; \
    echo "opcache.save_comments=1"; \
    echo "opcache.file_cache=${OPCACHE_FILE_CACHE_DIR}"; \
    echo "opcache.file_cache_size=128"; \
    echo "opcache.file_cache_only=0"; \
    echo "opcache.file_cache_consistency_checks=1"; \
    } >> "$PHP_INI_FILE" && \
    if grep -q "^date.timezone" "$PHP_INI_FILE"; then \
        sed -i "s#^date.timezone.*#date.timezone = $TIMEZONE#g" "$PHP_INI_FILE"; \
    else \
        echo "date.timezone = $TIMEZONE" >> "$PHP_INI_FILE"; \
    fi

# 定义 Nginx 配置文件
RUN echo ' \
server { \
    listen 80; \
    server_name _; \
    root /app; \
    index index.php; \
    location / { \
        if (!-e $request_filename) { \
            rewrite ^(.*)$ /index.php?s=$1 last; \
            break; \
        } \
    } \
    location ~ \.php$ { \
        fastcgi_pass 127.0.0.1:9000; \
        fastcgi_index index.php; \
        include fastcgi_params; \
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \
    } \
    # 启用 gzip 压缩 \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml; \
    gzip_vary on; \
    gzip_min_length 1000; \
    gzip_proxied any; \
    gzip_comp_level 6; \
    gzip_buffers 16 8k; \
    gzip_http_version 1.1; \
    \
    # 优化静态文件缓存 \
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg)$ { \
        expires max; \
        add_header Cache-Control "public"; \
    } \
}' > /opt/docker/etc/nginx/vhost.conf

RUN chown -R application:application /app \
    && chmod -R 755 /app
