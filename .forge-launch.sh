#!/usr/bin/env bash
# Launcher for Forge Code, opened by forge.bat in the same directory.
# Runs INSIDE WSL Ubuntu (linux ELF bash + linux ELF forge), with cwd already
# set to /mnt/c/<this-folder> by `wsl.exe --cd "<windows path>"` in forge.bat.
#
# Why this version (v5):
#   v2 mintty+bash+forge.exe       broke arrows/backspace (MSYS pty wrapped a Windows console app)
#   v3 wt+bash+forge.exe + pcon    froze after one prompt
#   v4 wt+pwsh+forge.exe           still froze after one prompt
#   v5 wt+wsl+bash+forge (Linux)   no MSYS layer, real Linux pty, native input

set -u

HERE="$(pwd)"
LOG="$HERE/.forge-launch.log"

{
  echo "=== $(date '+%Y-%m-%d %H:%M:%S') WSL forge launch ==="
  echo "PWD=$HERE"
  echo "TERM=${TERM:-unset}"
  echo "SHELL=bash $BASH_VERSION (WSL Ubuntu)"
  command -v forge >/dev/null && forge --version
  uname -a
} > "$LOG" 2>&1

forge "$@"
code=$?

echo "=== forge exited with code $code at $(date '+%H:%M:%S') ===" >> "$LOG"

if [ $code -ne 0 ]; then
  echo
  echo "Forge exited with code $code. See .forge-launch.log for details."
  echo "[Press Enter to drop to bash prompt]"
  read -r _
fi

exec bash -l
