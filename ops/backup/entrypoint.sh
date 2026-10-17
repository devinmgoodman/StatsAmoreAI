#!/bin/sh
# Sleeps until BACKUP_TIME (container TZ) each day, then runs backup.sh. No cron needed.
set -eu
while true; do
  now=$(date +%s)
  next=$(date -d "$(date +%Y-%m-%d) ${BACKUP_TIME:-02:30}:00" +%s)
  [ "$next" -le "$now" ] && next=$((next + 86400))
  echo "$(date -Iseconds) next backup in $((next - now))s"
  sleep $((next - now))
  /usr/local/bin/backup.sh || echo "$(date -Iseconds) BACKUP FAILED"
done
