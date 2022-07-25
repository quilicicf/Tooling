#------#
# Diff #
#------#

# Displays the history of a file
# $1: search pattern (fed to find)
gkf() {
  local pattern="${1?Missing search pattern}"
  local files filesNumber
  files="$(find . -name "$pattern" | grep -v target)"
  filesNumber="$(wc -l <<< "$files")"

  if [ "$filesNumber" = "1" ]; then
    gitk --all "$files" &

  else
    printfc "Expected 1 file with pattern '$pattern', found $filesNumber." "$RED"
    exit 1
  fi
}

# Opens gitk with all branches
# Uses: gitk
alias gka="gitk --all &"

# Opens gitk to inspect two local branches
# Uses: gitk
# $1: the first branch to inspect
# $2: the second branch to inspect
gk() {
  gitk "$1" "$2" &
}
