#---------#
# Screens #
#---------#

# Rearranges my connected monitors to presets. If called without arguments, removes all extra monitors.
# Existing preset: -o = office
# Existing preset: -h = home
screens() {
  local paramsConfig='{"o":{"hasValue": false, "isRequired": false, "type": "boolean"}, "h": {"hasValue": false, "isRequired": false, "type": "boolean"}, "s": {"hasValue": false, "isRequired": false, "type": "boolean"}}'
  local params="$(setParams "$paramsConfig" "$@")"

  if isTrue "$(jsonGet '.o' <<< "$params")"; then
    xrandr --output DP1 --auto --above eDP1
    xrandr --output HDMI1 --auto --rotate left --left-of DP1

  elif isTrue "$(jsonGet '.h' <<< "$params")"; then
    xrandr --output HDMI1 --auto --above eDP1

  else
    xrandr --output HDMI1 --off
    xrandr --output HDMI2 --off
    xrandr --output DP1 --off
    xrandr -s 0

  fi
}
