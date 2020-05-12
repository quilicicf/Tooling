#-----------#
# Processes #
#-----------#

# Launches the given program
# p: the program
# e: if set, exits the terminal after launch
# d: if set, disowns the program from the terminal
launch() {
  local params exitAfter program disownAfter

  local paramsConfig='{"p": {"type": "string","hasValue": true, "isRequired": true}, "e": {"type": "boolean","hasValue": false, "isRequired": false}, "d": {"type": "boolean","hasValue": false, "isRequired": false}}'
  params="$(setParams "$paramsConfig" "$@" || { return 1; })"

  program="$(jsonGet '.p' <<< "$params")"
  exitAfter="$(jsonGet '.e' <<< "$params")"
  disownAfter="$(jsonGet '.d' <<< "$params")"

  eval "$program" &

  isTrue "$disownAfter" && { disown; }
  isTrue "$exitAfter" && { exit 0; }
}

# Shows the processes listening to a specified port
# $1: the port
showbyport() {
  local port
  port="$(readInt "failure" "$1")"
  if [[ "$port" == "failure" ]]; then
    printf 'Invalid port number: %s\n' "$1"
    return 1
  fi

  lsof -i "tcp:$port" 2> /dev/null | tail -n +2 | awk '{print $1 " " $2}'
}

# Kills the processes listening to a specified port
# $1: the port
killbyport() {
  local processes name pid
  local hasError='false'
  local port="${1?Missing port number}"
  processes="$(showbyport "$1")" || { printf 'Nothing using port %s\n' "$port"; return 1; }

  while read -r process; do
    name="$(awk '{print $1}' <<< "$process")"
    pid="$(awk '{print $2}' <<< "$process")"

    if kill "$pid"; then
      printf 'Killed process %s (pid=%s)\n' "$name" "$pid"
    else
      printf 'Could not kill %s:%s on port %s\n' "$name" "$pid" "$port"
      hasError='true'
    fi
  done <<< "$processes"

  [[ "$hasError" == 'false' ]] # Set the error code
}

# Shows a process's PID given its name
# $1: the name of the process
showbyname() {
  pgrep "$1" | egrep -e "[0-9]{3,}"
}

# Kills a process's given its name
# Uses: showbyname
# $1: the name of the process
killbyname() {
  local pid
  pid="$(showbyname "$1")"
  kill "$pid"
}

# Plays success or failure sound, depending on last process execution.
# If sounds are not present on the computer, only writes the result of the process.
# Uses: _signalResult
signalResult() {
  if [ "${PIPESTATUS[0]}" -eq 0 ]; then
      _signalResult "$PRIVATE_TOOLING/sounds/alarm.mp3" "$GREEN" 'Process SUCCEEDED, you beautiful madafaka!'
  else
      _signalResult "$PRIVATE_TOOLING/sounds/fail.mp3" "$RED" 'Process FAILED, loser!'
  fi
}

# Uses: soundMute soundUnmute
_signalResult() {
  local mp3="${1?Missing mp3 file}"
  local color="${2?Missing text color}"
  local message="${3?Missing message}"

  if test -f "$mp3"; then
    soundMute
    mplayer "$mp3" -softvol -volume 200
    soundUnmute
  else
    printfc "Sound $mp3 not found!" "$RED"
  fi

  printfc "$message\n" "$color"
}
