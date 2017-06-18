#------#
# Pull #
#------#

# Fetches the specified remote
gf() {
  local remoteNickName remote
  remoteNickName=${1:--o}
  shift
  git fetch "$(gRemote "$remoteNickName")" "$@"
}

# Fetches the given remote then rebases current branch on it
# Uses: grbr, gRemote, git
# $1: the remote's nick name (Values: -u, -U, -o)
gfrb() {
  local remote remoteNickName
  remoteNickName="${1:--o}"
  remote="$(gRemote "$remoteNickName")"
  git fetch "$remote"
  grbr "$remoteNickName"
}

# Rebases current branch on the given remote
# Uses: git_branch_simple
# $1: the remote's nick name (Values: -u, -U, -o)
grbr() {
  local remote remoteNickName
  remoteNickName="${1:--o}"
  remote="$(gRemote "$remoteNickName")"
  git rebase "$remote/$(git_branch_simple)" || { echo "Looks like there are conflicts boy"; return 1; }
}

# Aborts the current merge
alias gma="git merge --abort"

# Switches to the dev branch (ex: 3.6), rebases it to its remote state, switches back to the previous branch and rebases it
# Uses: git_branch_simple, mergeTo, git, popb, gfrbu, grb
# $1: -v to rebase on version branch, -f for feature branch or the name of the branch to rebase on
__git_complete garb _git_branch
garb() {
  local motherBranch remoteNickName
  motherBranch=$(mergeTo "$1")
  remoteNickName="${2:--o}"
  git checkout "$motherBranch"
  gfrb "$remoteNickName"
  popb
  git rebase "$motherBranch"
}
