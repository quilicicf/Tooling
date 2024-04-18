#!/usr/bin/env bash

xdotool key 'XF86AudioPrev'
sleep '0.1' # Wait for vlc to switch songs
newTrack="$(
  lsof -wc 'vlc' \
    | grep music \
    | grep --only-matching '[^/]*$'
)"

notify-send \
  --icon "$FORGE/github/quilicicf/Tooling/music/icon.png" 'Previous track ⏮' "${newTrack}"
