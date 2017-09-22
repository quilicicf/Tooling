#--------#
# Branch #
#--------#

# Displays current branch author
# Uses: JSON module, git_branch_simple
gbAuthor() {
  local description
  description="$(git config branch."$(git_branch_simple)".description)"
  jsonGet '.author' <<< "$description"
}

# Returns 0 if on a safe branch, 1 otherwise. A safe branch is a branch the current user created, master excluded.
# Uses: gbAuthor, git_branch_simple
gbIsSafeBranch() {
  [ "$(gbAuthor)" = "$GITHUB_ID" ] && [ "$(git_branch_simple)" != 'master' ]
}

# Sets the current branch's author.
# $1: author (default: current git user)
# Uses: JSON module, git_branch_simple
gbSetAuthor() {
  local author="${1:-$GITHUB_ID}"
  git config branch."$(git_branch_simple)".description "$(jsonSet '.author' "$author" "string" <<< '{}')"
}

# Shows local branches
# $1: the nickname of the remote (Values: -a, -l, -o, -u & -U)
# -s: strip the remote from the branch name (Optional)
# Uses: gRemote
gb() {
  local inputRemote remote
  local shouldStripRemote='false'

  inputRemote=$(readVar "-l" "$1" "-[alou]")
  remote=$(gRemote "$inputRemote")

  grepn -e '-s' <<< "$*" && { shouldStripRemote='true'; }

  if [ "$remote" = "local" ]; then
    git branch -a | grep -v /

  else
    local branchList=""
    if [ "$remote" = "all" ]; then
      branchList="$(git branch -a)"
    else
      branchList="$(git branch -a | grep "$remote" --color=never)"
    fi

    while read -r branch; do
      _stripRemoteNameIfNecessary "$branch" "$shouldStripRemote"
    done <<< "$branchList" | sort | uniq
  fi
}

_stripRemoteNameIfNecessary() {
  local fullBranch="$1"
  local shouldStripRemote="$2"
  if isTrue "$shouldStripRemote"; then
    if grepn -e 'remotes/' <<< "$fullBranch"; then
      printf '%s\n' "$fullBranch" | awk -F '[/]' '{print $3}'
    else
      printf '%s\n' "$fullBranch"
    fi
  else
    printf '%s\n' "$fullBranch"
  fi
}

# Finds a branch given its nickname
# $1: nickname, -v for version, -f for feature
gbe() {
  local branch="${1?Missing target branch}"
  if [ "$branch" = "-v" ]; then
    gbv
  elif [ "$branch" = "-f" ]; then
    gbf
  else
    echo 'master'
  fi
}

# Copies the current git branch to the clipboard.
# Uses: git_branch_simple, cb
cpb() {
  git_branch_simple | cbs
}

# Retrieves the current version branch by splitting the name of the current branch.
# Uses: git_branch_simple
gbv() {
  local branch
  branch="$(git_branch_simple)"
  echo "$branch" | awk -F '[_]' '{ print $1 }'
}

# Retrieves the current feature branch.
# Uses: git_branch_simple
gbf() {
  local branch
  branch="$(git_branch_simple)"
  echo "$branch" | awk -F '[_]' '{ print $1"_"$2 }'
}
