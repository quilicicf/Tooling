#----------------------#
# Refresh repositories #
#----------------------#

refreshRepositories() (
  baseFolder="${1:?Missing base folder}"
  pattern="${2:?Missing pattern}"

  cd "${baseFolder}"
  if [[ -f .envrc ]]; then
    source .envrc
  fi
  
  readarray repositories <<< "$(fd "${pattern}" --type 'd' --maxdepth '1')"
  for repositoryLine in "${repositories[@]}"; do
    repository="$(tr -d '\n' <<< "${repositoryLine}")"
    read -rp "Process ${repository}? (Y/n)\n" answer
    if [[ ! "${answer}" == 'n' ]]; then
      _refreshRepository "${repository}"
    fi
  done
)

_refreshRepository() (
  cd "$1"
  defaultBranch="$(git remote set-head origin --auto | awk '{print $4}')"
  if ! git diff --quiet; then
    read -rp 'Cleanup the repository, then press ENTER to continue\n'
  fi
  git checkout "${defaultBranch}"
  git pull
)
