#-------#
# Sound #
#-------#

# This will only work if your system has pactl.

export VOLUME_TINY='10000'
export VOLUME_SMALL='15000'
export VOLUME_MEDIUM='20000'
export VOLUME_STRONG='40000'
export VOLUME_MAX='65000'

# Mutes all applications on the computer
# Uses: _soundChangeMuteStatus
soundMute() (
  _soundChangeMuteStatus 1
)

# Un-mutes all applications on the computer
# Uses: _soundChangeMuteStatus
soundUnmute() (
  _soundChangeMuteStatus 0
)

# Changes the mute status for all applications on the computer
# $1: new mute status, 1 for muted, 0 for unmuted.
_soundChangeMuteStatus() (
  newMuteStatus="${1?Missing new mute status}"
  pactl list sink-inputs \
    | grep --regexp 'Sink Input #' \
    | awk -F '[#]' '{print $2}' \
    | tr --delete ' ' \
    | while read -r sinkId; do
      pactl set-sink-input-mute "${sinkId}" "${newMuteStatus}"
    done
)

# Changes the volume for all applications on the computer
# $1: new volume (Must be between 0 & 65000).
soundSetVolume() (
  newVolume="${1?Missing new volume}"
  [[ "${newVolume}" =~ ^[0-9]{1,5}$ ]] || {
    printfc "Can't set the volume to ${newVolume}, volume should be in range [ 0,65000 ]" "${RED}"
    return 1
  }

  pactl list sinks \
    | grep --regexp 'Sink #' \
    | awk -F '[#]' '{print $2}' \
    | tr --delete ' ' \
    | while read -r sinkId; do
      pactl set-sink-volume "${sinkId}" "${newVolume}"
    done
)

# Changes the volume for all applications on the computer
# $1: new volume (Must be between 0 & 65000).
soundGetVolume() (
  newVolume="${1?Missing new volume}"
  [[ "${newVolume}" =~ ^[0-9]{1,5}$ ]] || {
    printfc "Can't set the volume to ${newVolume}, volume should be in range [ 0,65000 ]" "${RED}"
    return 1
  }

  pactl list sinks \
    | grep --regexp 'Sink #' \
    | awk -F '[#]' '{print $2}' \
    | tr --delete ' ' \
    | while read -r sinkId; do
      pactl set-sink-volume "${sinkId}" "${newVolume}"
    done
)
