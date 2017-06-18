#-----#
# Sha #
#-----#

# Displays the last n commits' main information including sha.
# Can be called with only the number of commits as parameter or none to display only one.
# Uses: readInt, Params module, JSON module
# n: the number of commits to show (Default: 1)
# f: format to use, from your configured git aliases for git log (Default: ll)
# (e.g. if in gitconfig you have git ls = log --pretty=format:'%H', use -f ls)
# r: reverse, add it to show commits from older to newer
gshn() {
  [ $# -lt 2 ] && {
    _gshn -n "$(readInt 1 "$1")"
    return 0
  }

  _gshn "$@"
}

_gshn() {
  local params n format
  local paramsConfig='{"f": {"type": "string", "hasValue": true, "isRequired": false}, "r": {"type": "boolean", "hasValue": false, "isRequired": false}, "n": {"type": "integer", "hasValue": true, "isRequired": false}}';
  params="$(setParams "$paramsConfig" "$@")"

  n="$(readInt 1 "$(jqcr '.n' <<< "$params")")"
  format="$(jqcr '.f' <<< "$params")"
  isNull "$format" && { format='ll'; }

  if isTrue "$(jqcr '.r' <<< "$params")"; then
    printf '%s\n' "$(git "$format" "-$n" HEAD)" | tac
  else
    printf '%s\n' "$(git "$format" "-$n" HEAD)"
  fi
}
