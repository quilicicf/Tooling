#-------#
# Other #
#-------#

export EXTRACTED='{}'

# Echoes the nth part of a string cut by a specified delimiter
# $1: the string to split
# $2: the delimiter
# $3: the index (starts from 1)
splitAndGet() {
  echo -e "$1" | awk -F "[$2]" '{ print $'"$3"' }'
}

# Echoes the size of the table created by splitting a string with a specified delimiter
# $1: the string to split
# $2: the delimiter
splitAndSize() {
  echo -e "$1" | awk -F "[$2]" '{ print NF }'
}

# Executes a task in background and displays the time taken at completion. Must only be used for repetitive tasks that do not fail as it loses the traces
# $1: the script to execute
# $2: the name of the process for displaying purpose
timebox() {
  output=$({ time eval "$1" > /dev/null; } |& grep real)
  elapsedTime=$(echo "$output" | awk '{ print $2 }')
  printfc "$2 done in " "$CYAN"
  printfc "$elapsedTime\n" "$YELLOW"
}

# Nice markdown display
# Uses: pandoc
# $1: the name of the file to use
displaymd() {
  pandoc --standalone --from markdown --to html --metadata 'pagetitle=doc' <<< "$1" \
    | elinks -dump -dump-color-mode 1
}

# Give ownership to logged user
chme() (
  sudo chown --recursive "$(whoami):$(whoami)" "$@"
)

# Give execution rights on the given file
chx() (
  chmod +x
)

# Copies the current path to the clipboard
# Uses: cbs
cpDir() {
  pwd | cbs
}

# Extracts the nth group from the given input according to the given regex
# $1: the input text
# $2: the regex
# $3: the group number
# $4: the default value (Optional)
extract() (
  callerFn="${FUNCNAME[1]}"
  value="${1?Missing value to extract from}"
  regex="${2?Missing regex}"
  group="${3?Missing group number}"
  default="$4"

  if [[ "${value}" =~ $regex ]]; then
    EXTRACTED="$(jsonSet ".${callerFn}" "${BASH_REMATCH[${group}]}" "string" <<< "${EXTRACTED}")"
    return 0

  else
    if [[ -n "${default}" ]]; then
      EXTRACTED="$(jsonSet ".${callerFn}" "${default}" "string" <<< "${EXTRACTED}")"
    else
      return 1
    fi
  fi
)
