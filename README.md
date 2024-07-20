### Docker优化版acgfaka

- 镜像增加redis扩展
- 镜像增加opcache扩展
- 去除后台广告
- 优化打开速度



### Docker-compose 快速部署示例
```
version: '3.8'

services:
  acgfaka:
    image: ghcr.io/sky22333/acg-faka:latest
    ports:
      - "9000:80"
    depends_on:
      - mysql
      - redis
    restart: always

  mysql:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword    # 数据库的root用户密码
      MYSQL_DATABASE: acgfakadb            # 数据库名称
      MYSQL_USER: acgfakauser              # 数据库用户名称
      MYSQL_PASSWORD: acgfakapassword      # 数据库用户密码
    volumes:
      - /home/mysql:/var/lib/mysql
    restart: always

  redis:
    image: redis:latest
    restart: always
```
