#--------#
# Rebase #
#--------#

# Makes an interactive rebase (with autosquash) on the n last commits
# $1: the number of commits to rebase
grbn() {
  git rebase "HEAD~$1" -i --autosquash 2> /dev/null
}

# Aborts current rebase
alias grba="git rebase --abort"

# Continues current rebase
alias grbc="git rebase --continue"
