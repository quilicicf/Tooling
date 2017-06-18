#--------#
# Search #
#--------#

# Finds a file given its name and displays its path
# $1: the file name
# $2: the path in which to search for the file (default: .)
# Uses: xo
search() {
  local search=${1?Missing search at index 1}
  local dir=${2:-./}
  find "$dir" -name "$search"
}

# Finds a file given its name and opens it
# $1: the file name
# $2: the path in which to search for the file (default: .)
# Uses: xo
searchOpen() {
  local files=$(search "$@")
  local found=$(wc -l <<< "$files")

  if [ "$found" = "0" ]; then
    echo "No file found, too bad"
  elif [ "$found" = "1" ]; then
    xo "$files"
  else
    local choices='[]'
    local file
    while read -r file; do
      local choice=$(jsonSet '.label' "$file" 'string' <<< '{}' | jsonSet '.value' "$file" 'string')
      choices="$(jsonSet '.' "$choice" <<< "$choices")"
    done <<< "$files"

    intChoose "$choices" || { echo "Unknown error"; return 1; }
    isNull "$INTERACTIVE_CHOICE" && { echo "Operation aborted"; return 0; }
    xo "$INTERACTIVE_CHOICE"
  fi
}

# Finds all files given a regex and opens them
# $1: the file name
# $2: the path in which to search for the file (default: .)
# Uses: xo
searchOpenAll() {
  local files=$(search "$@")
  local found=$(wc -l <<< "$files")

  if [ "$found" = "0" ]; then
    echo "No file found, too bad"
  elif [ "$found" = "1" ]; then
    xo "$files"
  else
    local file
    while read -r file; do
      subl "$file"
    done <<< "$files"
  fi
}
