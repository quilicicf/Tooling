#-------#
# Sound #
#-------#

# This will only work if your system has pactl. 

export VOLUME_TINY='10000'
export VOLUME_SMALL='15000'
export VOLUME_MEDIUM='20000'
export VOLUME_STRONG='40000'
export VOLUME_MAX='65000'

# Mutes all appliations on the computer
# Uses: _soundChangeMuteStatus
soundMute() {
  _soundChangeMuteStatus 1
}

# Unmutes all appliations on the computer
# Uses: _soundChangeMuteStatus
soundUnmute() {
  _soundChangeMuteStatus 0
}

# Changes the mute status for all applications on the computer
# $1: new mute status, 1 for muted, 0 for unmuted.
_soundChangeMuteStatus() {
  local newMuteStatus="${1?Missing new mute status}"
  pactl list sink-inputs | \
  grep -e 'Sink Input #' | \
  awk -F '[#]' '{print $2}' | \
  tr -d ' ' | \
  while read -r sinkId; do
    pactl set-sink-input-mute "$sinkId" "$newMuteStatus"
  done
}

# Changes the volume for all applications on the computer
# $1: new volume (Must be between 0 & 65000).
soundSetVolume() {
  local newVolume="${1?Missing new volume}"
  [[ "$newVolume" =~ ^[0-9]{1,5}$ ]] || {
    printfc "Can't set the volume to $newVolume, volume should be in range [ 0,65000 ]" "$RED"
    return 1
  }

  pactl list sinks | \
  grep -e 'Sink #' | \
  awk -F '[#]' '{print $2}' | \
  tr -d ' ' | \
  while read -r sinkId; do
    pactl set-sink-volume "$sinkId" "${newVolume}"
  done
}

# Changes the volume for all applications on the computer
# $1: new volume (Must be between 0 & 65000).
soundGetVolume() {
  local newVolume="${1?Missing new volume}"
  [[ "$newVolume" =~ ^[0-9]{1,5}$ ]] || {
    printfc "Can't set the volume to $newVolume, volume should be in range [ 0,65000 ]" "$RED"
    return 1
  }

  pactl list sinks | \
  grep -e 'Sink #' | \
  awk -F '[#]' '{print $2}' | \
  tr -d ' ' | \
  while read -r sinkId; do
    pactl set-sink-volume "$sinkId" "${newVolume}"
  done
}
