###########
# Tooling #
###########

# Finds all the possible words containing the letters of the given trigram in the right order (ex: trif cqu en => CumQUat)
# Used to give the worts possible surnames to colleagues if you use trigrams in your company.
# Uses: dico-en.txt, dico-fr.txt, $PRIVATE_TOOLING
# $1: trigram
# $2: dico (values: en, fr; default: fr)
trif() {
  local trigram="${1?Missing trigram}"
  local dico="${2:-fr}"
  grep "^.*${trigram:0:1}.\{0,2\}${trigram:1:1}.\{0,2\}${trigram:2:1}.*$" "$PRIVATE_TOOLING/trif/dico-$dico.txt"
}

# Alias to xdg-open that silences it.
# Should be used to open a file (or URL) with the default system program.
xo() {
  local input
  [ -t 0 ] && {
    input="$*"
    for file in "$@"; do
      xdg-open "$file" &> /dev/null
    done
    return 0
  }
  [ -z "$input" ] && { input="$(cat)"; }
  while read -r file; do
    xdg-open "$file" &> /dev/null
  done <<< "$input"
}

# Gets the content of the primary clipboard and applies xdg-open on it.
# Should be used to open a file (or URL) with the default system program.
# Uses: xo
xoc() {
  xo "$(xclip -selection primary -o)"
}

# Opens with the default editor all the files that contain a specific regex in the sub-directories of the current directory
# Uses: xo
openalld() {
  local files
  files="$(grep -r "$1" -n . | awk -F '[:]' '{print $1}' | uniq -u)"
  while read -r fileName; do
    xo "$fileName"
  done <<< "$files"
}

# Opens all the files given in input
# Uses: xo
# $@: the files list
openall() {
  while read -r file; do
    [ "${#file}" -gt 1 ] && {
      echo "Opening: $file"
      xo "$file"
    }
  done <<< "$@"
}

# Returns a code 0 if the input is "true", 1 otherwise
# $1: the string to evaluate
isTrue() {
  [ -z "$1" ] && { return 1; }
  [ "$1" = "true" ] && { return 0; }
  return 1
}

# Returns a code 1 if the input is "true", 0 otherwise
# $1: the string to evaluate
isFalse() {
  if isTrue "$1"; then
    return 1
  else
    return 0
  fi
}

# Returns a code 1 if the input is "null" or empty, 0 otherwise
# $1: the value to check
isNotNull() {
  [ -z "$1" ] && { return 1; }
  [ "$1" = "null" ] && { return 1; }
  return 0
}

# Returns a code 1 if the input is "null" or empty, 0 otherwise
# Uses: isNotNull
# $1: the value to check
isNull() {
  if isNotNull "$1"; then
    return 1
  else
    return 0
  fi
}

# Returns its first non-null argument. Returns an error code when  all arguments are null.
# Uses: isNotNull
firstNonNull() {
  for entry in "$@"; do
    if isNotNull "$entry"; then
      echo "$entry"
      return 0
    fi
  done
  return 1
}

# Negates the given boolean
# Uses: isTrue
# $1: the boolean to negate
not() {
  if isTrue "$1"; then
    echo "false"
  else
    echo "true"
  fi
}
