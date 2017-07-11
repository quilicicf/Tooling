#--------#
# Commit #
#--------#

# Adds all files from the repo
# Uses: gDirty, gUnstaged
ga() {
  if [ "$(gDirty)" = "true" ] || [ "$(gUnstaged)" = "true" ]; then
    gitRepoTopLevel=$(git rev-parse --show-toplevel)
    if [ "$(pwd)" = "$gitRepoTopLevel" ]; then
      git add . -A
    else
      pushd "$gitRepoTopLevel"
      git add . -A
      popd
    fi
  fi
}

# Adds all the files in git status that match the given regex
# Uses: gstu
# $1: the regex
gareg() {
  gstu | grep "$1" | while read -r line; do
    file=$(echo "$line" | awk '{print $2}')
    git add "$file"
  done
}

# Commits the current changes with a commit message. The message will be appended the ticket number in either JIRA or Github: ex (#123) or (https://restlet.atlassian.net/browse/AS-300)
# Uses: repoPattern
# $1: the commit message
gcm() {
  local suffix=''
  [ -n "$(ticketNumber)" ] &> /dev/null && {
    suffix="$(repoPattern)"
  }

  local message="${1?Missing commit message} $suffix"
  shift
  git commit -m "$message" "$@"
}

# Commits the current staged changes with generic commit message ':eyes: Code review'
# Uses: gcm
gcrc() {
  gcm ":eyes: Code review"
}

# Same as gcm above but allows to provide a ticket number
# Uses: repoPattern
gcmt() {
  local suffix ticketNumber message
  ticketNumber="${2?Missing ticket number}"
  suffix="$(repoPattern "$ticketNumber")"
  message="${1?Missing commit message} $suffix"

  shift; shift
  git commit -m "$message" "$@"
}

# Returns a code 0 is the given commit is a merge commit, 1 otherwise.
# $1: the sha of the commit
isMergeCommit() {
  grepn "2" <<< "$(git log --pretty=%P -n 1 "${1?Missing commit sha at index 1}" \
  | tr ' ' '\n' \
  | wc -l)"
}

# Commits the current changes with a commit message prefixing by fixup! so that it can be easily squashed into the last commit
# Uses: gStaged, gstu, jqcr, isMergeCommit, isFalse, printfc, intConfirm, grepn, isNull
gcmb() {
  local lastCommit sha message
  isFalse "$(gStaged)" && { printfc "There are uncommitted changes !\n" "$RED"; gstu; return 1; }

  lastCommit="$(git lj --max-count=1)"
  sha="$(jqcr '.sha' <<< "$lastCommit")"
  message="$(jqcr '.message' <<< "$lastCommit")"

  isMergeCommit "$sha" && { printfc "Last commit is a merge commit. Cannot squash !" "$RED"; return 1; }

  intConfirm "Are you sure you want to squash on '$message' ?" || { return 0; }
  git commit -n --fixup "$sha"
}

# Displays the list of last commits, let's the user choose one of them to commit the current changes with a commit message prefixing by fixup! so that it can be easily squashed into it
# $1: number of commits to display
# $2: remote nickname to test for merge commits (values: -u, -l, -o, -U; default: -u)
# Uses: gStaged, gstu, jqcr, gRemote, isMergeCommit, isFalse, printfc, grepn, intChoose, isNull, JSON module
gcmbi() {
  local remoteId remote choices choice branch excludes sha message branches count maxIndex hasIndex
  isFalse "$(gStaged)" && { printfc "There are uncommitted changes !\n" "$RED"; gstu; return 1; }

  maxIndex=$1
  if [ "$maxIndex" == "" ]; then
    hasIndex='false'
  else
    hasIndex='true'
  fi

  remoteId=${2:--u}
  remote="$(gRemote "$remoteId")"
  choices='[]'
  branch="$(git_branch_simple)"
  excludes="$(jsonArrayize <<< "$remote/$branch")"

  printf 'Testing merge commits against remote: %b\n' "$(gColoredRemote "$remoteId")"

  local commit index
  index=1
  while read -r commit; do
    sha="$(jqcr '.sha' <<< "$commit")"
    message="$(jqcr '.message' <<< "$commit")"
    branches="$(git branch -r --contains "$sha" | jsonArrayize "$excludes")"

    if isTrue "$hasIndex"; then
      [ "$index" -gt "$maxIndex" ] && { break; }
    else
      isMergeCommit "$sha" && { break; }
      jqcr 'length' <<< "$branches" | grepn -v '0' && { break; }
    fi

    choice=$(jsonSet '.label' "$message" 'string' <<< '{}' | jsonSet '.value' "$sha" 'string')
    choices="$(jsonSet '.' "$choice" <<< "$choices")"
    ((index++))
  done <<< "$(git lj --max-count=10 "$branch")"

  intChoose "$choices" || { echo "Nothing to squash upon, is the first commit a merge commit ?"; return 1; }
  isNull "$INTERACTIVE_CHOICE" && { echo "Operation aborted"; return 0; }
  git commit -n --fixup "$INTERACTIVE_CHOICE"
}

# Cherry-picks the given commits
# $1: the shas, separated by one space or input via stdin
gcp() {
  local shas='[]'
  [ -t 0 ] && { shas="$(tr " " "\n" <<< "$@" | jsonArrayize)"; }
  [ -z "$shas" ] && { shas="$(cat | jsonArrayize)"; }

  local index=1
  count="$(jqcr length <<< "$shas")"
  while read -r sha; do
    _gcp "$sha" "$index" "$count"
    ((index++))
  done <<< "$(jqcr '.[]' <<< "$shas")"
}

# Cherry-picks a commit given its sha
# $1: the sha
_gcp() {
  local count sha
  sha="${1?Missing sha at index 1}"
  [ -n "$2" ] && { count=" ($2/$3)"; }
  printfc "Cherry-picking: $sha$count\n" "$CYAN"
  git cherry-pick "$sha" || {
    if [ "$2" == "$3" ]; then
      return 1
    else
      read -p "There were some errors, fix them then press enter"
    fi
  }
}

# Aborts the current cherry-pick
gcpa() {
  git cherry-pick --abort
}

# Continues the current cherry-pick
gcpc() {
  git cherry-pick --continue
}

# Displays a beautiful graph of added/removed code lines.
# $1: if entered, represents the number of commits to inspect. If not, the local changes are inspected. (Optional)
gin() {
  local diff addedLinesNumber removedLinesNumber pertenageAdded
  local commitsNumber=$1
  if [ "$commitsNumber" = "" ]; then
    diff="$(git --no-pager diff)"
  else
    [[ "$commitsNumber" =~ ^[1-9][0-9]*$ ]] || {
      printf 'First argument must be a number!\n'
      return 1
    }
    diff="$(git --no-pager diff "HEAD~$commitsNumber..HEAD")"
  fi

  addedLinesNumber="$(egrep -v "^[-+]{3} " <<< "$diff" | egrep '^\+' | wc -l)"
  removedLinesNumber="$(egrep -v "^[-+]{3} " <<< "$diff" | egrep '^\-' | wc -l)"
  local totalLineChangeNumber=$((addedLinesNumber + removedLinesNumber))

  [ "$totalLineChangeNumber" -eq "0" ] && {
    printfc "No lines updated!\n" "$CYAN"
    return 0
  }
  pertenageAdded="$(awk -v added="$addedLinesNumber" -v total="$totalLineChangeNumber" 'BEGIN{printf "%.0f", added / total * 10}')"

  printfc "+++ $addedLinesNumber " "$GREEN"
  for i in {1..10}; do
    if [ "$i" -le "$pertenageAdded" ]; then
      printfc " " "$GREEN"
    else
      printfc " " "$RED"
    fi
  done
  printfc "$removedLinesNumber --- \n" "$RED"
}
