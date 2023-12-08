#!/usr/bin/env bash

vlc --random ~/Documents/Backup/cyp/music & disown
notify-send \
  --icon "$FORGE/github/quilicicf/Tooling/music/icon.png" 'Starting music 🔀'
