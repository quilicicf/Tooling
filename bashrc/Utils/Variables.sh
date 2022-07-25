#-----------#
# Variables #
#-----------#

# Returns a default value if input not specified or not a boolean, input otherwise
# $1: the default value
# $2: the input
readBool() (
  readVar "$1" "$2" "(true|false)"
)

# Returns a default value if input not specified or not an integer, input otherwise
# Uses: readVar
# $1: the default value
# $2: the input
readInt() (
  readVar "$1" "$2" "[0-9]+"
)

# Returns a default value if input not specified, input otherwise
# $1: the default value
# $2: the input
# $3: the optional regex that the input should match
readVar() (
  if [[ -z "$2" ]]; then
    printf '%s\n' "$1"
    return 0
  else
    if [[ -n "$3" ]]; then
      regex="^$3$"
      if [[ "$2" =~ $regex ]]; then
        printf '%s\n' "$2"
        return 0
      else
        printf '%s\n' "$1"
        return 0
      fi
    else
      printf '%s\n' "$2"
      return 0
    fi
  fi
)
