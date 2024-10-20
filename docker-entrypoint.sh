#!/bin/bash

TARGET_DIR="/var/www/html"
TEMP_DIR="/tmp/html-temp"

if [ ! -d "$TARGET_DIR/config" ] || [ -z "$(ls -A $TARGET_DIR/config)" ]; then
    cp -r $TEMP_DIR/config $TARGET_DIR/
else
    echo "Config directory exists, skipping copy."
fi

rsync -a --exclude 'config' --exclude 'docker-entrypoint.sh' $TEMP_DIR/ $TARGET_DIR/

chown -R www-data:www-data $TARGET_DIR

chmod 777 "$TARGET_DIR/bin" "$TARGET_DIR/console.sh"

exec apache2-foreground
