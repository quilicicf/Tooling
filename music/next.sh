#!/usr/bin/env bash

xdotool key 'XF86AudioNext'
notify-send \
  --icon "$FORGE/github/quilicicf/Tooling/music/icon.png" 'Next track ⏭'
