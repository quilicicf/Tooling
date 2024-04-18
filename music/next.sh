#!/usr/bin/env bash

xdotool key 'XF86AudioNext'
sleep '0.1' # Wait for vlc to switch songs
newTrack="$(
  lsof -wc 'vlc' \
    | grep music \
    | grep --only-matching '[^/]*$'
)"

notify-send \
  --icon "$FORGE/github/quilicicf/Tooling/music/icon.png" 'Next track ⏭' "${newTrack}"
