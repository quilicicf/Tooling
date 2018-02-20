#--------#
# Rebase #
#--------#

# Alias for rebase
# Uses: gstu
__git_complete grb _git_rebase
grb() {
  git rebase "$@" || { printf 'Looks like there are conflicts boy !\n'; gstu; return 1; }
}

# Makes an interactive rebase (with autosquash) on the n last commits
# $1: the number of commits to rebase
grbn() {
  git rebase "HEAD~$1" -i --autosquash
}

# Makes an interactive rebase (with autosquash) on the 2 last commits
grbq() {
  grbn 2
}

# Aborts current rebase
alias grba="git rebase --abort"

# Continues current rebase
alias grbc="git rebase --continue"
