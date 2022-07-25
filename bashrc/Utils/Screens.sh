#---------#
# Screens #
#---------#

# Example configuration:
#{
#  "o": {
#    "left": {
#      "name": "DP-2",
#      "mode": "1920x1080",
#      "rate": 60.00
#    },
#    "right": {
#      "name": "DP-1",
#      "mode": "1920x1200",
#      "rate": 59.95
#    }
#  }
#}
export SCREENS_CONFIG_PATH=~/.screensConfig.json

xr() (
  mode="${1?Missing mode}"

  if [[ ! -f "${SCREENS_CONFIG_PATH}" ]]; then
    printf 'Screens configuration file missing: %s\n' "${SCREENS_CONFIG_PATH}"
    return 1
  fi

  location="${mode:0:1}"
  locationConfig="$(jq ".${location}" --compact-output < "${SCREENS_CONFIG_PATH}")"

  if [[ ! "$(jq 'type' --raw-output <<< "${locationConfig}")" == 'object' ]]; then
    printf 'Unknown mode location %s\n' "${location}"
    return 1
  fi

  leftConfig="$(jq '.left' <<< "${locationConfig}")"
  leftName="$(jq '.name' --raw-output <<< "${leftConfig}")"
  leftMode="$(jq '.mode' --raw-output <<< "${leftConfig}")"
  leftRate="$(jq '.rate' --raw-output <<< "${leftConfig}")"

  rightConfig="$(jq '.right' <<< "${locationConfig}")"
  rightName="$(jq '.name' --raw-output <<< "${rightConfig}")"
  rightMode="$(jq '.mode' --raw-output <<< "${rightConfig}")"
  rightRate="$(jq '.rate' --raw-output <<< "${rightConfig}")"

  activity="${mode:1:1}"
  if [[ "${activity}" == 'w' ]]; then
    xrandr \
      --output "${leftName}" --primary --mode "${leftMode}" --rate "${leftRate}" \
      --output "${rightName}" --mode "${rightMode}" --rate "${rightRate}" --right-of "${leftName}"

  elif [[ "${activity}" == 'g' ]]; then
    xrandr \
      --output "${leftName}" --off \
      --output "${rightName}" --mode "${rightMode}" --rate "${rightRate}" --primary

  else
    printf 'Unknown mode activity %s\n' "${activity}"
    return 1
  fi
)
