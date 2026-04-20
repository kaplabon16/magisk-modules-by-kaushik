\
#!/system/bin/sh
MODDIR=${0%/*}
LOGFILE=/data/local/tmp/realme8i_refresh.log
STATE=/data/local/tmp/realme8i_refresh_state
TOUCH_FLAG=/data/local/tmp/realme8i_touch_active
VIDEO_FLAG=/data/local/tmp/realme8i_video_mode
MOVIE_FLAG=/data/local/tmp/realme8i_movie_mode
TV_FLAG=/data/local/tmp/realme8i_tv_mode

POLL_MS=80
IDLE_TIMEOUT_MS=1800
READING_TIMEOUT_MS=1500
VIDEO_RECHECK_MS=100
GAME_RECHECK_MS=80
APP_RECHECK_MS=100

TARGET_IDLE=30
TARGET_SCROLL=120
TARGET_INFO_90=90
TARGET_INFO_120=120
TARGET_MOVIE=48
TARGET_TV=50
TARGET_VIDEO=60
TARGET_GAME=60
TARGET_DEFAULT=120

touch "$LOGFILE"
echo "$(date) - service start" >> "$LOGFILE"

until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 1
done
sleep 10

set_setting_refresh() {
  local hz="$1"

  settings put system peak_refresh_rate "$hz" 2>/dev/null
  settings put system min_refresh_rate "$hz" 2>/dev/null
  settings put secure peak_refresh_rate "$hz" 2>/dev/null
  settings put secure min_refresh_rate "$hz" 2>/dev/null
  settings put system user_refresh_rate "$hz" 2>/dev/null
  settings put system screen_refresh_rate "$hz" 2>/dev/null
  settings put secure user_refresh_rate "$hz" 2>/dev/null
  settings put secure screen_refresh_rate "$hz" 2>/dev/null

  for node in \
    /sys/devices/platform/soc/*/dsi_display_primary/dynamic_fps \
    /sys/devices/platform/soc/*/msm_drm/*/dynamic_fps \
    /sys/class/drm/card0-DSI-1/modes \
    /sys/class/graphics/fb0/dynamic_fps \
    /sys/class/graphics/fb0/idle_time \
    /proc/displowpower/hz \
    /proc/display_rate \
    /proc/refresh_rate ; do
      for realnode in $node; do
        [ -e "$realnode" ] && echo "$hz" > "$realnode" 2>/dev/null
      done
  done

  echo "$hz" > "$STATE"
  echo "$(date) - set ${hz}Hz" >> "$LOGFILE"
}

get_foreground_pkg() {
  dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' | head -n 1 | sed -E 's/.* ([A-Za-z0-9._]+)\/.*/\1/' | tr -d '\r'
}

is_screen_off() {
  dumpsys power 2>/dev/null | grep -q "Display Power: state=OFF"
}

is_dozing() {
  dumpsys deviceidle 2>/dev/null | grep -qi "mScreenOn=false"
}

video_mode_for_pkg() {
  pkg="$1"
  case "$pkg" in
    com.google.android.youtube|app.revanced.android.youtube|org.schabi.newpipe|com.mxtech.videoplayer.ad|com.netflix.mediaclient|com.amazon.avod.thirdpartyclient|com.google.android.apps.youtube.music)
      echo "video"
      ;;
    org.videolan.vlc|com.mxtech.videoplayer.pro)
      echo "movie"
      ;;
    *)
      echo "none"
      ;;
  esac
}

tv_mode_for_pkg() {
  pkg="$1"
  case "$pkg" in
    com.sonyliv|in.startv.hotstar|com.jio.media.ondemand|com.zee5.*|com.nextreaming.nexplayer*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_game_pkg() {
  pkg="$1"
  case "$pkg" in
    com.pubg.imobile|com.tencent.ig|com.dts.freefireth|com.mobile.legends|com.activision.callofduty.shooter|com.madfingergames.legends|com.riotgames.*|com.supercell.*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_info_stream_pkg() {
  pkg="$1"
  case "$pkg" in
    com.facebook.katana|com.instagram.android|com.zhiliaoapp.musically|com.twitter.android|com.reddit.frontpage|com.linkedin.android|com.ss.android.ugc.trill|com.google.android.apps.magazines|com.android.chrome|org.mozilla.firefox)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

(
  while true; do
    getevent -qlc 1 2>/dev/null | grep -qE 'ABS_MT|BTN_TOUCH|EV_KEY|EV_ABS'
    if [ $? -eq 0 ]; then
      date +%s%3N > "$TOUCH_FLAG"
    fi
  done
) &

LAST_HZ=""
LAST_INPUT=0

while true; do
  now=$(date +%s%3N)

  if is_screen_off || is_dozing; then
    target=$TARGET_IDLE
  else
    pkg=$(get_foreground_pkg)
    [ -z "$pkg" ] && pkg="unknown"

    if [ -f "$TOUCH_FLAG" ]; then
      LAST_INPUT=$(cat "$TOUCH_FLAG" 2>/dev/null)
    fi
    [ -z "$LAST_INPUT" ] && LAST_INPUT=0

    delta=$((now - LAST_INPUT))

    if is_game_pkg "$pkg"; then
      target=$TARGET_GAME
    else
      mode=$(video_mode_for_pkg "$pkg")
      if tv_mode_for_pkg "$pkg"; then
        target=$TARGET_TV
      elif [ "$mode" = "movie" ]; then
        target=$TARGET_MOVIE
      elif [ "$mode" = "video" ]; then
        target=$TARGET_VIDEO
      elif is_info_stream_pkg "$pkg"; then
        if [ "$delta" -lt 900 ]; then
          target=$TARGET_INFO_120
        else
          target=$TARGET_INFO_90
        fi
      else
        if [ "$delta" -lt 350 ]; then
          target=$TARGET_SCROLL
        elif [ "$delta" -lt "$READING_TIMEOUT_MS" ]; then
          target=$TARGET_DEFAULT
        elif [ "$delta" -lt "$IDLE_TIMEOUT_MS" ]; then
          target=$TARGET_IDLE
        else
          target=$TARGET_IDLE
        fi
      fi
    fi
  fi

  if [ "$target" != "$LAST_HZ" ]; then
    set_setting_refresh "$target"
    LAST_HZ="$target"
  fi

  usleep 80000 2>/dev/null || sleep 0.08
done
