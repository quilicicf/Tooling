#------#
# Diff #
#------#

# Displays the history of a file
# $1: search pattern (fed to fd)
gkf() (
  pattern="${1?Missing search pattern}"
  files="$(fd "${pattern}")"
  filesNumber="$(wc -l <<< "${files}")"

  if [[ "${filesNumber}" == "1" ]]; then
    printf 'Found file %s\n' "${files}"
    gitk --all "${files}" &

  else
    printfc "Expected 1 file with pattern '${pattern}', found ${filesNumber}:\n${files}" "$RED"
    exit 1
  fi
)

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
