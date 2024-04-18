#!/usr/bin/env bash

vlc --random ~/Documents/Backup/cyp/music & disown

sleep '0.5' # Wait for vlc to switch songs
newTrack="$(
  lsof -wc 'vlc' \
    | grep music \
    | grep --only-matching '[^/]*$'
)"

notify-send \
  --icon "$FORGE/github/quilicicf/Tooling/music/icon.png" 'Starting music 🔀' "${newTrack}"
