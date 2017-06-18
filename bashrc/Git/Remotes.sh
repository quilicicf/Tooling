#---------#
# Remotes #
#---------#

export REMOTES
REMOTES="$(<"$BASHRC/Git/remotes.json")"

# Returns the colored full name of the remote given its contraction.
# $1: the contracted remote name (values: -l, -o, -u & -U)
gColoredRemote() {
  local name color
  local id=${1?Missing remote id at index 1}
  name=$(jqcr ".[\"$id\"].name" <<< "$REMOTES")
  color=$(jqcr ".[\"$id\"].color" <<< "$REMOTES")
  printfc "$name" "${!color}"
}

# Returns the full name of the remote given its contraction.
# $1: the contracted remote name (values: -l, -o, -u & -U)
gRemote() {
  local id=${1?Missing remote id at index 1}
  printf "%s" "$(jqcr ".[\"$id\"].name" <<< "$REMOTES")"
}

# Returns the delete instruction for a remote given its contraction.
# $1: the contracted remote name (values: -l, -o, -u & -U)
gDeleteInstruction() {
  local id=${1?Missing remote id at index 1}
  printf "%s" "$(jqcr ".[\"$id\"].deleteInstruction" <<< "$REMOTES")"
}
