#--------------#
# PR utilities #
#--------------#

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


# Opens a PR page on github for the current branch on origin
# Uses: git_branch_simple, repoName, mergeTo, gprl, intChoose, isNull, $GITHUB_ID
# $1: either -v to PR on the version branch or -f for the feature branch or the name of the branch to merge to (default: feature branch, see gprbf)
# $2: the organization on which to merge, by default, that of the upstream of the current branch
__git_complete gpr _git_branch
gpr() {
  gprl
  local currentBranch org project orgAndProjectRegex result title titleChoices

  currentBranch=$(git_branch_simple)
  mergeTo=$(mergeTo "$1")

  remote="$(git config "branch.$(git_branch_simple).remote")" || {
    printf 'Cannot find a remote for the current branch\n'
    return 1
  }

  orgAndProjectRegex='[ ]*Fetch URL: git@github\.com:([^/]+)\/([^.]+)\.git$'

  [[ "$(git remote show "$remote" | egrep "Fetch URL: ")" =~ $orgAndProjectRegex ]] || {
    printf 'No remote found for "origin"\n'
    return 1
  }

  org="${BASH_REMATCH[1]}"
  project="${BASH_REMATCH[2]}"

  remoteOrg=${2:-$org}

  titleChoices="$(_prTitleChoices)"

  printf "Choose the PR's title\n"
  intChoose "$titleChoices" || { echo "Unknown error"; return 1; }
  isNull "$INTERACTIVE_CHOICE" && { echo "Operation aborted"; return 0; }
  title="$INTERACTIVE_CHOICE"

  result="$(curl -X POST \
     -H "Content-Type:application/json" \
     -H "Accept:application/json" \
     -H "Authorization:Bearer $GITHUB_TOKEN" \
     -d \
  "{
    \"title\": \"$title\",
    \"head\": \"$org:$currentBranch\",
    \"base\": \"$mergeTo\"
  }" \
  "https://api.github.com/repos/$remoteOrg/$project/pulls")"

  if isTrue "$(jq 'has("html_url")' <<< "$result")"; then
    jq -r ".html_url" <<< "$result" | cbs
    xo "$(cbo)"

    local message channel shouldPost shouldLanuchBuild

    printf 'Post a message on slack (y/n): '
    read shouldPost
    [ "$shouldPost" = 'n' ] && { return 0; }

    printf 'Which channel sir (default: dev-dhc): '
    read channel
    [ -z "$channel" ] && { channel='dev-dhc'; }

    printf 'Which message sir (default: same as PR): '
    read message
    [ -z "$message" ] && { message="PR pour $title"; }

    curl -X POST --data-urlencode "payload={\"channel\": \"#$channel\", \"username\": \"cyp\", \"text\": \"$message: $(cbo)\", \"icon_emoji\": \":nazi_mustache:\"}" ***REMOVED*** \
    > /dev/null

    printf 'Launch a build ? (y/n): '
    read shouldLanuchBuild
    [ "$shouldLanuchBuild" = 'y' ] && { gjenks; }

  elif isTrue "$(jq 'has("errors")' <<< "$result")"; then
    printf '\n%s\n' "$(jq -r '.errors[0].message' <<< "$result")"
    return 1

  else
    printf '\nCannot create PR for unknown reason, server returned:\n"%s"\n' "$result"
    return 1

  fi
}

_prTitleChoices() {
  local title choice
  local choices='[]'
  while read -r title; do
    local choice=$(jsonSet '.label' "$title" 'string' <<< '{}' | jsonSet '.value' "$title" 'string')
    choices="$(jsonSet '.' "$choice" <<< "$choices")"
  done <<< "$(git lm -10)"

  printf '%s' "$choices"
}

# Opens jenkins page to launch an automated test suite. Copies the current branche's name to the clipboard so that one just has to copy it in jenkins.
# Uses: cpb, xo, repoJob, isNotNull
gjenks() {
  local repoJob
  cpb
  repoJob="$(repoJob)"

  if isNotNull "$repoJob"; then
    xo "$repoJob"
  else
    echo "No job configured for this repository"
    return 1
  fi
}
