FROM webdevops/php-nginx:8.1-alpine

USER root

RUN git clone https://github.com/lizhipay/mcy-shop.git && \
    chown -R application:application /mcy-shop && \
    chmod -R 755 /mcy-shop && \
    cd mcy-shop && \
    echo "www ALL=(ALL) NOPASSWD: /usr/bin/nginx" >> /etc/sudoers && \
    echo "www ALL=(ALL) NOPASSWD: /usr/sbin/service nginx" >> /etc/sudoers && \
    echo "application ALL=(ALL) NOPASSWD: /usr/bin/nginx" >> /etc/sudoers && \
    echo "application ALL=(ALL) NOPASSWD: /usr/sbin/service nginx" >> /etc/sudoers && \
    echo "www ALL=(ALL) NOPASSWD: /mcy-shop/bin" >> /etc/sudoers && \
    echo "application ALL=(ALL) NOPASSWD: /mcy-shop/composer" >> /etc/sudoers && \
    composer install --optimize-autoloader && \
    mkdir -p /app/opcache_cache_dir && \
    chown -R application:application /app/opcache_cache_dir && \
    { \
        echo "[opcache]"; \
        echo "opcache.enable=1"; \
        echo "opcache.memory_consumption=256"; \
        echo "opcache.interned_strings_buffer=16"; \
        echo "opcache.max_accelerated_files=5000"; \
        echo "opcache.revalidate_freq=5"; \
        echo "opcache.save_comments=1"; \
        echo "opcache.file_cache=/app/opcache_cache_dir"; \
        echo "opcache.file_cache_size=128"; \
        echo "opcache.file_cache_only=0"; \
        echo "opcache.file_cache_consistency_checks=1"; \
    } >> /opt/docker/etc/php/php.ini

# 定义 Nginx 配置文件
RUN echo ' \
server { \
    listen 80; \
    server_name _; \
    root /mcy-shop; \
    index index.php; \
    \
    # 处理404和重写规则 \
    location ~ ^/(LICENSE|README\.md|config|kernel|runtime|vendor) { \
        return 404; \
    } \
    \
    location / { \
        try_files $uri $uri/ /index.php?_route=$uri; \
    } \
    \
    location ~ \.php$ { \
        fastcgi_pass 127.0.0.1:9000; \
        fastcgi_index index.php; \
        include fastcgi_params; \
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \
    } \
    \
    # Gzip 压缩配置 \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml; \
    gzip_vary on; \
    gzip_min_length 1000; \
    gzip_proxied any; \
    gzip_comp_level 6; \
    gzip_buffers 16 8k; \
    gzip_http_version 1.1; \
}' > /opt/docker/etc/nginx/vhost.conf