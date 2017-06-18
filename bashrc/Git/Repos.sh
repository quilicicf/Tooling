#-------------#
#    Repos    #
#-------------#

export REPOS_CONFIG
REPOS_CONFIG="$(jqcr '.' <  "$BASHRC/Git/repos.json")"

# Jump to a repo
# $1: nickname of the repo to jump to
j() {
  local repo path
  repo="$(_getRepoFromNickName "${1?Missing nickname at index 1}")"
  path="$(jsonGet '.path' <<< "$repo")"

  if isNull "$path"; then
    echo "No path found"
    return 1
  else
    cd "${!path}"
  fi
}

# Retrieves the repository name from its nickname
# $1: The nickname of the repo
_getRepoFromNickName() {
  local nickname="${1?Missing nickname}"
  jsonValues "$REPOS_CONFIG" | while read -r repo; do
    if [ "$nickname" = "$(jsonGet '.nickname' <<< "$repo")" ]; then
      echo "$repo"
      return 0
    fi
  done
  return 1
}

# Adds the headers defined in the file repos.headers to each class of the repo.
# Currently, it only works with java repos !
# Uses: repoHeaders, repoLocalPath
repoAddheaders() {
  local headers files
  headers="$(repoHeaders || { echo "No headers for this repository"; return 1; })"

  pushd "$(repoLocalPath)/modules"
  files=$(grep --include ".*\.java" -r '^package ' -n . | grep ":1:" | awk -F '[:]' '{print $1}')
  while read -r file; do
    sed -i "1i \ $headers" "$file"
  done <<< "$files"
  popd
}

# Returns the repository's name.
# Uses: repoLocalPath, Json module, Params module
# j: json-friendly, when set, changes the repo name to a JSON-friendly one by replacing '-' by '_'
repoName() {
  local paramsConfig params sanitized
  paramsConfig='{"j":{"hasValue": false, "isRequired": false, "type": "boolean"}}'
  params="$(setParams "$paramsConfig" "$@")"

  if isTrue "$(jsonGet '.j' <<< "$params")"; then
    sanitized="$(basename "$(repoLocalPath)")"
    echo "${sanitized//-/_}"
  else
    basename "$(repoLocalPath)"
  fi
}

# Displays the top level of the current git repository
repoLocalPath() {
  git rev-parse --show-toplevel
}

# Cds to the top level of the current git repository
# Uses: repoLocalPath
uptop() {
  cd "$(repoLocalPath)"
}

# Prints the main language of the current repo given its name
# Uses: $BASHRC, repoName, Json module
# $1: name of the repo (values: restlet-studio, apispark-console, restlet-framework-java, restlet-framework-apispark, apispark)
repoLanguage() {
  local repoLanguage defaultLanguage
  repoLanguage="$(jsonGet ".$(repoName -j).language" <<< "$REPOS_CONFIG")"
  defaultLanguage="$(jsonGet ".default.language" <<< "$REPOS_CONFIG")"
  firstNonNull "$repoLanguage" "$defaultLanguage"
}

# Prints the current ticket number using the current repository's pattern
# Uses: $BASHRC, repoName, Json module
# $1: the ticket number (Optional: otherwise, retrieved from branch number)
repoPattern() {
  local ticketNumber="$1"
  [ -z "$ticketNumber" ] && {
    # shellcheck disable=SC2034
    ticketNumber="$(ticketNumber)"
  }

  local repoPattern
  repoPattern="$(jsonGet ".$(repoName -j).pattern" <<< "$REPOS_CONFIG")"

  if [ -n "$ticketNumber" ]; then
    printf '%s\n' "${repoPattern/\$ticketNumber/$ticketNumber}"
  else
    printf ''
  fi
}

# Prints the build job for the current repo
# Uses: $BASHRC, repoName, Json module
repoJob() {
  jsonGet ".$(repoName -j).job" <<< "$REPOS_CONFIG"
}

# Prints the headers to be prepended to every source code file for the current repo
# Uses: $BASHRC, repoName, mget
repoHeaders() {
  local repoHeaders
  repoHeaders="$(jsonGet ".$(repoName -j).headers" <<< "$REPOS_CONFIG")"
  firstNonNull "$repoHeaders" || { echo "No headers for this repository"; return 1; }
}
