#-----------#
# Processes #
#-----------#

# Shows the processes listening to a specified port
# $1: the port
showByPort() (
  port="$(readInt "failure" "$1")"
  if [[ "${port}" == "failure" ]]; then
    printf 'Invalid port number: %s\n' "$1"
    return 1
  fi

  lsof -i "tcp:${port}" 2> /dev/null \
    | tail -n +2 \
    | awk '{print $1 " " $2}'
)

# Kills the processes listening to a specified port
# $1: the port
killByPort() (
  hasError='false'
  port="${1?Missing port number}"
  processes="$(showByPort "$1")" || {
    printf 'Nothing using port %s\n' "${port}"
    return 1
  }

  while read -r process; do
    name="$(awk '{print $1}' <<< "${process}")"
    pid="$(awk '{print $2}' <<< "${process}")"

    if kill "${pid}"; then
      printf 'Killed process %s (pid=%s)\n' "${name}" "${pid}"
    else
      printf 'Could not kill %s:%s on port %s\n' "${name}" "${pid}" "${port}"
      hasError='true'
    fi
  done <<< "${processes}"

  [[ "${hasError}" == 'false' ]] # Set the error code
)

# Shows a process's PID given its name
# $1: the name of the process
showByName() {
  pgrep "$1" | grep -E "[0-9]{3,}"
}

# Kills a process's given its name
# Uses: showByName
# $1: the name of the process
killByName() (
  pid="$(showByName "$1")"
  kill "${pid}"
)

# Plays success or failure sound, depending on last process execution.
# If sounds are not present on the computer, only writes the result of the process.
# Uses: _signalResult
signalResult() {
  if [[ "${PIPESTATUS[0]}" -eq 0 ]]; then
    _signalResult "${PRIVATE_TOOLING}/sounds/alarm.mp3" "${GREEN}" 'Process SUCCEEDED, you beautiful madafaka!'
  else
    _signalResult "${PRIVATE_TOOLING}/sounds/fail.mp3" "${RED}" 'Process FAILED, loser!'
  fi
}

# Uses: soundMute soundUnmute
_signalResult() (
  mp3="${1?Missing mp3 file}"
  color="${2?Missing text color}"
  message="${3?Missing message}"

  if [[ -f "${mp3}" ]]; then
    soundMute
    printf 'Playing %s\n' "$(basename "${mp3}")"
    mplayer "${mp3}" -softvol -volume 200 &> /dev/null
    soundUnmute
  else
    printfc "Sound ${mp3} not found!" "${RED}"
  fi

  printfc "${message}\n" "${color}"
)
