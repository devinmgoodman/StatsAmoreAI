#!/bin/sh
# pg_dump (custom format) -> /backups, prune old dumps, optionally copy off-site.
# Sundays are kept as "weekly" (56 days); other days as "daily" (14 days).
# Restore: pg_restore -h postgres -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists <file>
set -eu
kind=daily
[ "$(date +%u)" = 7 ] && kind=weekly
f="/backups/${POSTGRES_DB}-$(date +%Y%m%d-%H%M%S)-${kind}.dump"

PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -h postgres -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc -f "$f.tmp"
pg_restore -l "$f.tmp" >/dev/null # sanity check: archive is readable
mv "$f.tmp" "$f"
echo "$(date -Iseconds) wrote $f ($(du -h "$f" | cut -f1))"

find /backups -name "${POSTGRES_DB}-*-daily.dump" -mtime +14 -delete
find /backups -name "${POSTGRES_DB}-*-weekly.dump" -mtime +56 -delete

if [ -n "${RCLONE_REMOTE:-}" ]; then
  rclone copy "$f" "$RCLONE_REMOTE" && echo "$(date -Iseconds) uploaded to off-site remote"
else
  echo "$(date -Iseconds) RCLONE_REMOTE not set; skipping off-site copy"
fi
