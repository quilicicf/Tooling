#-------------#
#    Repos    #
#-------------#

export REPOS_CONFIG REPO_NAMES
REPOS_CONFIG="$(jqcr '.' <  "$BASHRC/Git/repos.json")"

test -f "$PRIVATE_TOOLING/bashrc/Git/repos.json" && {
  REPOS_CONFIG="$(jqcr -s '.[0] * .[1]' "$TOOLING/bashrc/Git/repos.json" "$PRIVATE_TOOLING/bashrc/Git/repos.json")"
}


# Jump to a repo
# $1: search string for the repo
j() {
  local search="${1?Missing search}"
  local choices repos
  repos="$(find "$FORGE" -maxdepth 1 -printf '%f\n' | jq -R -s -c 'split("\n")')"

  choices="$(jqn --color=false "filter(name => /$search/.test(name.toLowerCase())) | map(name => { return { label: name, value: name }; })" <<< "$repos")"
  choicesSize="$(jqcr 'length' <<< "$choices")"

  if [[ "$choicesSize" -gt 1 ]]; then
    intChoose "$choices"
    isNull "$INTERACTIVE_CHOICE" && { echo "Operation aborted"; return 0; }
    cd "$FORGE/$INTERACTIVE_CHOICE"

  elif [[ "$choicesSize" = "0" ]]; then
    printf 'No repository matching your search. Check the search and the repos.\n'
    return 1

  else
    cd "$FORGE/$(jqcr "first | .value" <<< "$choices")"

  fi
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
