#-------#
# Clone #
#-------#

# Clones the given repo in the directory forge
# Uses: $FORGE, git
# $1: organization or organization/project
# $2: project or nothing
# TODO: add the repo in repos.json
gcl() {
  local location

  if [ $# -gt 1 ]; then
    project="${2?Missing project}"
    location="${1?Missing organization}/$project"
  else
    location="${1?'Missing organization/project'}"
    project="$(awk -F '[/]' '{print $2}')"
  fi

  pushd "$FORGE"
  printf 'Trying to clone: %s\n' "$location"
  git clone "git@github.com:$location.git" || { echo "Cloning failed"; popd; return 1; }

  cd "$project"
}
