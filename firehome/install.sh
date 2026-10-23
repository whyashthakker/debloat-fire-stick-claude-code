#!/usr/bin/env bash
# Build and install the app home on a Fire TV, let its watcher read the log, and open it.
# Usage:   TV_HOST=192.168.1.50 firehome/install.sh
#          TV_HOST=192.168.1.50 FIREHOME_APPS="com.amazon.firetv.youtube com.spotify.tv.android" firehome/install.sh
#          (the tiles, in order; YouTube alone by default. Package names: tools/tv.py "pm list packages -3")
# Undo:    TV_HOST=192.168.1.50 firehome/install.sh --remove     (Amazon's home is back on the next Home press)
set -euo pipefail
cd "$(dirname "$0")/.."
PY=tools/venv/bin/python
[ -x "$PY" ] || PY=tools/venv/Scripts/python.exe
[ -x "$PY" ] || { echo "run: python3 -m venv tools/venv && tools/venv/bin/pip install -r tools/requirements.txt"; exit 1; }
# Git Bash would turn /data/local/tmp into a Windows path before the Windows Python sees it; only here, since
# build.sh's d8.bat needs JAVA_HOME converted
tv() { MSYS_NO_PATHCONV=1 "$PY" -I tools/tv.py "$@"; }

if [ "${1:-}" = "--remove" ]; then
  printf '%s\n' "pm uninstall com.firehome" "input keyevent 3" | tv --batch
  exit 0
fi

read -ra LIST <<< "${FIREHOME_APPS:-com.amazon.firetv.youtube}"
# the list goes into a shell command on the TV, so only bare package names get through
for app in "${LIST[@]}"; do
  [[ "$app" =~ ^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$ ]] || { echo "not a package name: $app" >&2; exit 1; }
done
APPS="$(IFS=,; echo "${LIST[*]}")"

firehome/build.sh
tv --push firehome/build/firehome.apk /data/local/tmp/firehome.apk
# READ_LOGS lets the watcher see Home presses. Fire OS drops accessibility services set over ADB, but grants this.
printf '%s\n' \
  "pm install -r /data/local/tmp/firehome.apk" \
  "rm /data/local/tmp/firehome.apk" \
  "pm grant com.firehome android.permission.READ_LOGS" \
  "am start -n com.firehome/.HomeActivity --es apps $APPS" | tv --batch
