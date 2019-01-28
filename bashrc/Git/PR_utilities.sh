#--------------#
# PR utilities #
#--------------#

export PR_SETTINGS='{"defaultChannel": "general"}'
export PR_SETTINGS_FILE="$TOOLING/bashrc/Git/pr.json"

if test -f "$PR_SETTINGS_FILE"; then
  PR_SETTINGS="$(jqcr '.' < "$PR_SETTINGS_FILE")"
else
  printfc "A configuration file has been created for the PR feature at " "$YELLOW"
  printfc "$PR_SETTINGS_FILE\n" "$CYAN"
  printfc "Feel free to update it to your wishes.\n" "$YELLOW"
  jq <<< "$PR_SETTINGS" > "$PR_SETTINGS_FILE"
fi

# Parses all the feature's commits to find omissions. Each repo has a different script
# Uses: repoLanguage, gdn, gprfc, $repo.awk files, gin
# $1: the optional number of commits to rewind
gprl() {
  local language size
  language=$(repoLanguage)
  size=$(readInt "1" "$(gprfcn "")")
  gin "$size"
  gdn "$size" | gawk -f "$TOOLING/awk/$language.awk"
}

# Parses the current unstaged changes or the given number of commits to find omissions. Each repo has a different script
# Uses: repoLanguage, $repo.awk files
# $1: optional number of commits to inspect
gl() {
  local language
  language=$(repoLanguage)

  if [ "$(readInt 0 "$1")" = "0" ]; then
    gin
    git diff | gawk -f "$AWKPATH/$language.awk"
  else
    gin "$1"
    gdn "$1" | gawk -f "$AWKPATH/$language.awk"
  fi
}

# Updates the current PR by commiting and squashing the current changes, force pushing them to origin and parsing the diff for omissions
# $1: optional, is set to -i, will allow the user to choose the commit to squash upon
# Uses: ga, gcmb, grbpr, gpsf, gStaged
gupr() {
  ga
  isFalse "$(gStaged)" && { printf "No changes to commit\n"; return 0; }
  [ "$1" = "-i" ] && { gcmbi; }
  [ "$1" != "-i" ] && { gcmb; }
  grbpr
  gpsf
}

# Updates the current PR by commiting and squashing the current changes, force pushing them to upstream and parsing the diff for omissions
# $1: optional, is set to -i, will allow the user to choose the commit to squash upon
# Uses: ga, gcmb, grbpr, gpsfu, gStaged
gupru() {
  ga
  isFalse "$(gStaged)" && { printf "No changes to commit\n"; return 0; }
  [ "$1" = "-i" ] && { gcmbi; }
  [ "$1" != "-i" ] && { gcmb; }
  grbpr
  gpsfu
}

# Updates the last commit by commiting and squashing the current changes into it. Parses the diff omisisons
# Uses: ga, gcmb, grbq, gprl, gStaged
gucm() {
  ga
  isFalse "$(gStaged)" && { printf "No changes to commit\n"; return 0; }
  [ "$1" = "-i" ] && { gcmbi; }
  [ "$1" != "-i" ] && { gcmb; }
  grbq
  gprl
}

# Rebases all the commits from the first of the feature, displays list of omissions
# Uses: grbn, gprfcn, gprl
grbpr() {
  grbn "$(gprfcn "")"; gprl;
}

# Gets the ticket number from the branch name.
# Fails if it doesn't find it
# Uses: git_branch_simple
ticketNumber() {
  local value
  awk -F '_' '{print $2; print $3;}' <<< "$(git_branch_simple)" | \
   while read -r value; do
    [[ "$value" =~ ^[0-9]+$ ]] && { printf '%s\n' "$value"; return 0; }
  done
}

# Returns the first commit in rewinded history that is not only in the current branch. Tries by searching the ticket number in the commits first, if none is present, falls back to searching the first commit that is also in origin or upstream.
# Uses: git lo, readInt, gprfcn
# TODO: use git-local
# $1: the number of commits to inspect, how far in history (default: 50)
gprfc() {
  local maxCount ticketNumber result
  ticketNumber=$(ticketNumber)
  maxCount=$(readInt 50 "$1")

  if [ -z "$ticketNumber" ]; then
    result=$(git lo "-$maxCount" HEAD | egrep -e "(upstream|origin)" | awk -F '[@]' '{print $1}'); [[ $? == 1 ]] && echo "" > /dev/null
    if [ -z "$result" ]; then
      echo "$result"
      return 0
    fi
  fi

  gsh "$(gprfcn "")"
}

# Returns the numbers of commits in history that have the current ticket number in their commit message
# Uses: repoPattern, git lo, readInt
# $1: the number of commits to inspect, how far in history (default: 50)
gprfcn() {
  local maxCount repoPattern regex ticketNumber
  local number=0

  maxCount=$(readInt 50 "$1")
  ticketNumber=$(readInt "" "$(splitAndGet "$(git_branch_simple)" "_" 2)")
  repoPattern="$(repoPattern)"
  regex="^.*$repoPattern.*$"

  while read -r log; do
    grepn -e "Merge" <<< "$log" && break
    grepn -v -e "$regex" <<< "$log" && break
    ((number += 1))
  done <<< "$(git lo "-$maxCount" HEAD)"
  echo "$number"
}

# Returns the first commit in rewinded history that has no fixup! in its message, adds an offset if provided with one
# Uses: git lo
# $1: the number of commits to inspect, how far in history (default: 50)
# $2: optional, if set the commit returned is $2 commits before the commit found by the algorithm in the history
gprfnf() {
  maxCount=$(readInt 50 "$1")
  offset=$(readInt 0 "$2")

  fixupCommitNumber=$(git lo "-$maxCount" HEAD | egrep "^.*fixup!.*$" | wc -l)
  fixupCommitNumber=$(( fixupCommitNumber + 1 + offset ))
  gsho "$fixupCommitNumber"
}

# Returns the branch to merge to
# Uses: gbv, gbf
# $1: either -v to PR on the version branch or -f for the feature branch or the name of the branch to merge to (default: version)
mergeTo() {
  if [ "$1" = "-v" ];then
    gbv
  elif [ "$1" = "-f" ]; then
    gbf
  elif [ "$1" = "-m" ]; then
    echo "master"
  elif [ -n "$1" ]; then
    echo "$1"
  else
    gbv
  fi
}
