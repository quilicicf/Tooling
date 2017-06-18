#-------#
# State #
#-------#

# Returns true if the current repo is in a dirty state, false otherwise
gDirty() {
  local dirty="false"
  git diff --no-ext-diff --quiet --exit-code || { dirty="true"; }
  printf '%s' "$dirty"
}

# Returns true if the current repo has staged changes, false otherwise
gStaged() {
  local staged="false"
  git diff-index --cached --quiet HEAD -- || { staged="true"; }
  printf '%s' "$staged"
}

# Returns true if the current repo has unstaged changes, false otherwise
gUnstaged() {
  if [ -n "$(git ls-files --others --exclude-standard --error-unmatch -- '*' 2>/dev/null)" ];then
    printf "true"
  else
    printf "false"
  fi
}
