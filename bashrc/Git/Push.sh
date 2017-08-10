#------#
# Push #
#------#

# Resets, hard
grsh() {
  git reset --hard
}

# Undoes the n last commits and puts all the changes in the stash, named by the last commit's message
# Uses: grsn, ga, gsth, gDirty
# $1: the number of commits to undo (Default: 1)
gundo() {
  local commitMessage numberOfCommits
  isTrue "$(gDirty)" && { printf 'Can only undo commit on a clean repo.\n'; return 1;  }

  numberOfCommits=${1:-1}
  commitMessage="$(git log --pretty=format:'%s' -1 HEAD)"
  grsn "$numberOfCommits"
  ga
  gsth save "$commitMessage"
}

# Deletes all untracked added files/folders
# Uses: gstu
grmh() {
  local line regex item
  gstu | while read -r line; do
    regex='^\?\?'
    if [[ "$line" =~ $regex ]]; then
      item="$(echo "$line" | awk '{ print $2 }')"
      if [ -f "$item" ]; then
        echo "Removing file $item"
        rm "$item" > /dev/null
      fi

      if [ -d "$item" ]; then
        echo "Removing folder $item"
        rm -rf "$item" > /dev/null
      fi
    fi
  done
}

# Resets the last n commits
# $1: the number of commits to reset
grsn() {
  git reset "HEAD~$1"
}

# Pushes to given remote
# Uses: gRemote, git_branch_simple
# $1: The remote's nickname, see remotes.json for options (Default: -o for origin)
gps() {
  local remote
  remote="$(gRemote "${1:--o}")"
  git push --set-upstream "$remote" "$(git_branch_simple)"
}

# Creates a code review comments commit and pushes it to specified remote
# Uses: gcrc, gps
# $1: The remote's nickname, see remotes.json for options (Default: -o for origin)
gpsrc() {
  gcrc; gps "$@"
}

# Pushes tags to given remote
# Uses: gRemote
gpst() {
  local remote
  remote="$(gRemote "${1:--o}")"
  git push "$remote" --tags
}

# Force pushes to given remote
# Uses: git_branch_simple, gRemote
gpsf() {
  local remote
  remote="$(gRemote "${1:--o}")"
  git push -f "$remote" "$(git_branch_simple)"
  git branch --set-upstream-to="$remote/$(git_branch_simple)"
}
