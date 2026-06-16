#!/usr/bin/env bash
# Usage:
#   ./luna_cron.sh start   – register the every-10-min cron job
#   ./luna_cron.sh stop    – remove the cron job
#   ./luna_cron.sh status  – show whether the job is active

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JULIA="$(command -v julia 2>/dev/null || echo julia)"
LOG="$SCRIPT_DIR/luna.log"

# The cron line – edit SSH_* variables here if needed
CRON_LINE="*/10 * * * * cd $SCRIPT_DIR && SSH_USERNAME=fignasi SSH_HOSTNAME=marcus.ace.chalmers.se SSH_KEY_PATH=/home/odisi/.ssh/luna_key $JULIA --project=. main.jl >> $LOG 2>&1 && git add luna.log && git commit -m 'cron: update luna.log' >> $LOG 2>&1 && tail -n 500 $LOG > $LOG.tmp && mv $LOG.tmp $LOG"

# Unique marker so we can find/remove exactly this job
MARKER="LUNA_READ"
FULL_CRON_LINE="$CRON_LINE  # $MARKER"

case "$1" in
  start)
    if crontab -l 2>/dev/null | grep -q "$MARKER"; then
      echo "LUNA cron job is already active."
    else
      (crontab -l 2>/dev/null; echo "$FULL_CRON_LINE") | crontab -
      echo "LUNA cron job started (every 10 minutes)."
    fi
    ;;
  stop)
    if crontab -l 2>/dev/null | grep -q "$MARKER"; then
      crontab -l 2>/dev/null | grep -v "$MARKER" | crontab -
      echo "LUNA cron job stopped."
    else
      echo "LUNA cron job is not active."
    fi
    ;;
  status)
    if crontab -l 2>/dev/null | grep -q "$MARKER"; then
      echo "LUNA cron job is ACTIVE:"
      crontab -l | grep "$MARKER"
    else
      echo "LUNA cron job is INACTIVE."
    fi
    ;;
  log)
    if [ ! -f "$LOG" ]; then
      echo "No log file found at $LOG"
      exit 1
    fi
    echo "=== Last 10 readings from $LOG ==="
    # Each reading starts at "Reading iteration started" and ends at "Reading finished"
    grep -E "Reading iteration started|Reading finished|PostgreSQL upload|Failed to upload|Warning|ch1 to be uploaded" "$LOG" \
      | tail -40
    ;;
  *)
    echo "Usage: $0 {start|stop|status|log}"
    exit 1
    ;;
esac
