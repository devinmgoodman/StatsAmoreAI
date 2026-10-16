FROM postgres:15-alpine
RUN apk add --no-cache rclone tzdata
COPY entrypoint.sh backup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/backup.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
