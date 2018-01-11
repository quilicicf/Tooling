#---------#
# Screens #
#---------#

# Rearranges my connected monitors to presets. If called without arguments, removes all extra monitors.
# Existing preset: -o = office
# Existing preset: -h = home
screens() {
  local paramsConfig='{"o":{"hasValue": false, "isRequired": false, "type": "boolean"}, "h": {"hasValue": false, "isRequired": false, "type": "boolean"}, "g": {"hasValue": false, "isRequired": false, "type": "boolean"}}'
  local params
  params="$(setParams "$paramsConfig" "$@")"

  if isTrue "$(jsonGet '.o' <<< "$params")"; then
    xrandr --output HDMI1 --auto
    xrandr --output DP1 --left-of HDMI1 --auto
    xrandr --output eDP1 --off

  elif isTrue "$(jsonGet '.g' <<< "$params")"; then
    xrandr --output DP1 --auto
    xrandr --output HDMI1 --off
    xrandr --output eDP1 --off

  elif isTrue "$(jsonGet '.h' <<< "$params")"; then
    xrandr --output HDMI1 --auto --above eDP1

  else
    xrandr --output HDMI1 --off
    xrandr --output HDMI2 --off
    xrandr --output DP1 --off
    xrandr -s 0

  fi
}
