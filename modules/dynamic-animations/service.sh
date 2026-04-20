#!/system/bin/sh
MODDIR=${0%/*}
STATE_DIR=/data/adb/dynamic_animations
LOG=$STATE_DIR/module.log
PIDFILE=$STATE_DIR/daemon.pid
LASTTOUCH=$STATE_DIR/last_touch_ms
mkdir -p "$STATE_DIR"
: > "$LOG"

log() {
  echo "$(date) - $1" >> "$LOG"
}

# Adjust animation scales based on refresh rate
adjust_animations() {
  # Check the refresh rate and adjust animations accordingly
  refresh_rate=$(cat /sys/class/graphics/fb0/refresh_rate)
  if [ "$refresh_rate" -ge 90 ]; then
    # Faster animations for higher refresh rates (e.g., 120 Hz)
    settings put global window_transition_scale 0.65
    settings put global transition_animation_scale 0.70
  elif [ "$refresh_rate" -ge 60 ]; then
    # Medium animations for moderate refresh rates (e.g., 60 Hz)
    settings put global window_transition_scale 0.80
    settings put global transition_animation_scale 0.85
  else
    # Slower animations for lower refresh rates (e.g., 30 Hz)
    settings put global window_transition_scale 1.0
    settings put global transition_animation_scale 1.0
  fi
}

# Main loop to continuously adjust animations
(
  while true; do
    adjust_animations
    sleep 2
  done
) &
echo $! > "$PIDFILE"
log "Dynamic animations daemon pid=$(cat "$PIDFILE")"
log "----- dynamic animations run end -----"