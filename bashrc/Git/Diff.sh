#------#
# Diff #
#------#

# Displays the beautified status of the current branch changes
gstu() {
  git status -sb
}

# Alias to git stash
alias gsth="git stash"

# Alias to git difftool
gdt(){
  launch -d -p "git difftool -d $*"
}

# Displays the diff between HEAD and HEAD - n with the favorite difftool
# Uses: gdtnm
# $1: the number of commits to inspect
gdtn() {
  local commitsNumber="$1"
  shift
  gdtnm "$commitsNumber" "0" "$@"
}

# Displays the diff between HEAD - n and HEAD - m with the favorite difftool
# Uses: readInt, readVar
# $1: the distance in the commit history of the oldest commit (default: 1)
# $2: the distance in the commit history of the newest commit (default: 0)
gdtnm() {
  local n m
  n=$(readVar 1 "$1" "[1-9][0-9]*")
  shift
  m=$(readInt 0 "$1")
  shift
  if [ "$m" = "0" ]; then
    gdt "HEAD~$n..HEAD" "$@"
  else
    gdt "HEAD~$n..HEAD~$m" "$@"
  fi
}

# Displays the diff between HEAD and HEAD - n with git's diff
# Uses: gdnm
# $1: the number of commits to inspect
gdn() {
  gdnm "$1" "0"
}

# Displays the diff between HEAD - n and HEAD - m with git's diff
# Uses: readInt, readVar
# $1: the distance in the commit history of the oldest commit (default: 1)
# $2: the distance in the commit history of the newest commit (default: 0)
gdnm() {
  n=$(readVar 1 "$1" "[1-9][0-9]*")
  m=$(readInt 0 "$2")
  if [ "$m" = "0" ]; then
    git diff "HEAD~$n..HEAD"
  else
    git diff "HEAD~$n..HEAD~$m"
  fi
}

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
    colorize "Expected 1 file with pattern '$pattern', found $filesNumber." "$RED"
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
