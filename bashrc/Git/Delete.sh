#--------#
# Delete #
#--------#

# Deletes a local branch
# $1: the local branch to delete
__git_complete gbd _git_branch
gbd() {
  git branch -D "$1"
}

# Deletes all the branches that have already been merged into the current branch on the given remote and prunes.
# Never erases master and the current branch.
# Uses: intConfirm, gColoredRemote, gRemote
# $1: remote nickname (Values: -o, -u or -l; Default: -l)
# $2: regex the branches to delete must match (Optional)
gbdmi() {
  local current mergedBranches remote coloredRemote deleteInstruction branchesToDeleteNumber
  current=$(git_branch_simple)
  mergedBranches=$(git branch -a --merged | grep -v master | grep -v "$current" | tr -d '[:blank:]')

  local remoteId="${1:--l}"
  remote=$(gRemote "$remoteId")
  coloredRemote=$(gColoredRemote "$remoteId")
  deleteInstruction=$(gDeleteInstruction "$remoteId")

  local regex="$2"

  local branchesToDelete
  if [ "$remote" = "local" ]; then
    branchesToDelete="$(grep -v "remotes" <<< "$mergedBranches")"

  else
    git fetch --prune "$remote"
    branchesToDelete="$(grep "$remote" <<< "$mergedBranches")"

  fi

  [ -n "$regex" ] && {
    branchesToDelete="$(egrep -e "$regex" <<< "$branchesToDelete")"
  }

  branchesToDeleteNumber=$(echo "$branchesToDelete" | wc -l)

  if [ -z "$branchesToDelete" ]; then
    echo "No existing branches have been merged into $current."
  else
    echo "This will remove the following branches:"
    if [ -n "$branchesToDelete" ]; then
      echo "$branchesToDelete"
    fi
    intConfirm "Are you sure you want to delete $branchesToDeleteNumber branches from $coloredRemote ?" || { echo "No branch removed"; return 0; }

    local branchNumber=1
    local branch
    while read -r branch; do
      local simpleBranch=${branch//remotes\/$remote\//}
      echo "$branchNumber/$branchesToDeleteNumber"
      eval "$deleteInstruction $simpleBranch"
      branchNumber=$(( branchNumber + 1 ))
    done <<< "$branchesToDelete"
  fi
}

# Deletes a branch on all locations (origin, upstream, local)
# Uses: intConfirm
# $1: the branch to delete
__git_complete gbda _git_branch
gbda() {
  local branch_to_delete="${1?Missing branch to delete}"
  gbd "$branch_to_delete"; gbdo "$branch_to_delete"; gbdu "$branch_to_delete";
}

# Deletes a branch on origin
# Uses: intConfirm
# $1: the branch to delete
__git_complete gbdo _git_branch
gbdo() {
  _gbdr '-o' "$1"
}

# Deletes a branch on upstream
# Uses: intConfirm
# $1: the branch to delete
__git_complete gbdu _git_branch
gbdu() {
  _gbdr '-u' "$1"
}

# Deletes a branch on the given remote
# Uses: intConfirm, gColoredRemote, gRemote
# $1: the branch to delete
_gbdr() {
  local fullRemote
  local simpleRemote=${1?Missing remote at index 1}
  fullRemote=$(gRemote "$simpleRemote")
  local branch=${2:-$(git_branch_simple)}
  intConfirm "Are you sure you want to delete $(printfc "$branch" "$YELLOW") from $(gColoredRemote "$simpleRemote") ?" || { return 0; }

  git push "$fullRemote" --delete "$branch"
}

# Deletes all the branches in a given repo that match a given regex.
# Uses: gb, gRemote, gColoredRemote, readVar, intConfirm
# $1: the location (values: -l, -o, -u)
# $2: the regex
gbdreg() {
  local remote colored_remote branches_to_delete branches_to_delete_number
  local input_remote=${1?Missing input remote at index 1}
  local regex=${2?Missing regex at index 2}
  remote=$(gRemote "$input_remote")
  colored_remote=$(gColoredRemote "$input_remote")

  branches_to_delete="$(gb "$input_remote" | grep -wv master | grep -wv "$(git_branch_simple)" | tr -d '[:blank:]' | egrep -e "^.*?$regex")"

  local delete_instruction
  if [ "$remote" = "local" ]; then
    delete_instruction="git branch -D "

  else
    git fetch --prune "$remote"
    delete_instruction="git push --delete $remote "

  fi

  branches_to_delete_number=$(echo "$branches_to_delete" | wc -l)

  if [ -z "$branches_to_delete" ]; then
    echo "No existing branches match the regex."
  else
    echo "This will remove the following branches:"
    if [ -n "$branches_to_delete" ]; then
      echo "$branches_to_delete"
    fi
    intConfirm "Are you sure you want to delete $branches_to_delete_number branches from $colored_remote ?" || { echo "No branch removed"; return 0; }

    local branch_number=1
    local branch
    while read -r branch; do
      local simple_branch=${branch//remotes\/$remote\//}
      echo "$branch_number/$branches_to_delete_number"
      eval "$delete_instruction $simple_branch"
      branch_number=$(( branch_number + 1 ))
    done <<< "$branches_to_delete"
  fi
}

# Deletes a local tag
__git_complete gtd _git_branch
gtd() {
  git tag -d "$1"
}

# Deletes a tag on upstream
__git_complete gtdu _git_branch
gtdu() {
  git push --delete upstream "$1"
}

# Deletes a tag on origin
__git_complete gtdo _git_branch
gtdo() {
  git push --delete origin "$1"
}
