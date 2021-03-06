#--------------#
# PR utilities #
#--------------#

export JENKINS_FILE="$PRIVATE_TOOLING/jenkins.json"

test -f "$JENKINS_FILE" || {
  printfc "Please type your API credentials in $JENKINS_FILE" "$RED"
  printf '{\n  "login": "",\n  "password": ""\n}\n' > "$JENKINS_FILE"
}

# Launches a local copy of Jenkins 2
jenkins() {
  local logFile
  logFile="$(mktemp -t "jenkins_logs_XXX_$(date +"%Y_%m_%dT%H_%M_%S")")"

  printf 'Log file is: %b%s%b\n' "$CYAN" "$logFile" "$DEFAULT"
  pushd "$WORK"
    nohup java -jar jenkins.war > "$logFile" 2>&1 &
    xo http://localhost:8080
  popd
}

# Opens jenkins page to launch an automated test suite. Copies the current branche's name to the clipboard so that one just has to copy it in jenkins.
# Uses: cpb, xo, repoJob, isNotNull
gjenks() {
  local repoJob
  cpb
  repoJob="$(repoJob)"

  if isNotNull "$repoJob"; then
    curl -X POST "$repoJob" \
      --user "$(jsonGet '.login' < "$JENKINS_FILE"):$(jsonGet '.password' < "$JENKINS_FILE")" \
      --data-urlencode json="{\"parameter\": [{\"name\": \"branch_or_tag\", \"value\":\"$(git_branch_simple)\"}]}"
    else
    echo "No job configured for this repository"
    return 1
  fi
}
