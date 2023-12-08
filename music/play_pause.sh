#!/usr/bin/env bash

xdotool key 'XF86AudioPlay'
notify-send \
  --icon "$FORGE/github/quilicicf/Tooling/music/icon.png" 'Play/pause ⏯'
