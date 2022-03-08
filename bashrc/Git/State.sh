#-------#
# State #
#-------#

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