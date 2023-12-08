#!/usr/bin/env bash

xdotool key XF86AudioPrev
notify-send \
  --icon "$FORGE/github/quilicicf/Tooling/music/icon.png" 'Previous track ⏮'
