FROM php:8.0-apache

# 安装必要的依赖和扩展
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        zlib1g-dev \
        libzip-dev \
        default-mysql-client \
        redis-tools \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip pdo_mysql opcache \
    && a2enmod rewrite deflate \
    && sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录并复制代码
WORKDIR /var/www/html
COPY . .

# 复制并安装 Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN composer install --no-dev --optimize-autoloader

# 设置环境变量
ENV MYSQL_HOST=localhost \
    MYSQL_USER=root \
    MYSQL_PASSWORD=password \
    MYSQL_DATABASE=your_database_name \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    OPCACHE_FILE_CACHE_DIR=/var/www/html/opcache_cache_dir \
    PHP_INI_FILE=/usr/local/etc/php/php.ini \
    TIMEZONE="Asia/Shanghai" \

# 配置 OPcache
RUN mkdir -p "$OPCACHE_FILE_CACHE_DIR" && \
    chown -R www-data:www-data "$OPCACHE_FILE_CACHE_DIR" && \
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

# 设置权限并暴露端口
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
