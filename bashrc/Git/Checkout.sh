#----------#
# Checkout #
#----------#

# Switches to a given branch and adds it to the branch history
# Uses: git
# $1: the branch name
__git_complete gco _git_checkout
gco() {
  local target="${1?Missing target branch}"
  git checkout "$1"
  local author description
  description="$(git config branch."$(git_branch_simple)".description)"
  author="$(jsonGet '.author' <<< "$description")"
  if isNull "$author"; then
    # TODO: if I'm the only committer, it shouldn't be set to public.
    gbSetAuthor 'public'
  fi
}

# Switches to a given branch and adds it to the branch history
# Uses: gco, gbe
# $1: the branch nickname (either -v, -f or -m)
gcoe() {
  local target="${1?Missing target branch}"
  gco "$(gbe "$target")"
}

# Checkouts all the files in git status that match the given regex
# Uses: gstu, gco
# $1: the regex
gcoreg() {
  local file line
  gstu | grep "$1" | while read -r line; do
    file=$(echo "$line" | awk '{print $2}')
    gco "$file"
  done
}

# Creates a new branch given a name, switches to it and adds it to the branch history
# Uses: git
# $1: the branch name
__git_complete gcob _git_checkout
gcob() {
  git checkout -b "$1"
  gbSetAuthor "$GITHUB_ID"
}

# Creates a new branch given a ticket number and a description and switches to it
# Uses: gcob
# $1: the ticket number
# $@: the description as words separated by spaces
gcobi() {
  local ticket branch
  ticket="$1"
  shift

  name=""
  for var in "$@"; do
    name="$name $var"
  done

  branch=$(echo "$name" | tr ' ' '_')
  gcob "$(git_branch_simple)""_""$ticket""$branch"
}

# Switches to a branch that contains the given text in its name and adds it to branch history
# Uses: gb, gco
# $1: the text that should be contained in the branch
gcor() {
  local choices='[]'
  local choice branch
  while read -r branch; do
    if isNotNull "$branch"; then
      choice=$(jsonSet '.label' "$branch" 'string' <<< '{}' | jsonSet '.value' "$branch" 'string')
      choices="$(jsonSet '.' "$choice" <<< "$choices")"
    fi
  done <<< "$(gb -a -s | egrep -v "\*" | tr -d '[:blank:]' | egrep -i "$1")"

  intChoose "$choices" || { echo "No branches matched."; return 0; }
  isNull "$INTERACTIVE_CHOICE" && { echo "Operation aborted"; return 0; }
  gco "$INTERACTIVE_CHOICE"
}
