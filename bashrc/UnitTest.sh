##############
# Unit tests #
##############

# Yes, at a certain point, I found testing my aliases would be a good idea to prevent regressions.
# Needless to say, this might be the most forsaken module of all :-(

export TEST_RESULTS=()
export TEST_SUITE=""

# Initializes a new test suite
initializeTestSuite() {
  local callerFn="${FUNCNAME[1]}"
  TEST_RESULTS=()
  TEST_SUITE="$callerFn"
}

# Performs a unit test. Execute the given command and compares the result with the expectation.
# If the result does not match the expectations, the test is marked as failed.
# $1: the command to execute
# $2: the expected output
assertEquals() {
  local result=""
  local actual expected
  actual="$(eval "${1?Missing function to evaluate}")"
  expected="$(echo -e "${2?Missing expected value}")"
  if fgrep -wqs "$expected" <<< "$actual"; then
    result="$1  $2 $(printfc "" "$GREEN")"
  else
    result="$1  $2 $(printfc "" "$RED")"
  fi
  TEST_RESULTS+=("$result")
  echo "$result"
}

assertOk() {
  local result=""
  local code=0
  eval "$1" &> /dev/null || { code="$?"; }

  local truthy="false"
  [ "$code" = "0" ] && { truthy="true"; }
  [ "$2" = "-v" ] && { truthy="$(not "$truthy")"; }

  if isTrue "$truthy"; then
    result="$1  $code $(printfc "" "$GREEN")"
  else
    result="$1  $code $(printfc "" "$RED")"
  fi
  TEST_RESULTS+=("$result")
  echo "$result"
}

assertNotOk() {
  assertOk "$1" -v
}

# Check that the last test suite was executed without error. Returns a status of 1 if it is not the case.
# Outputs the results.
checkTestSuiteStatus() {
  local error_count
  error_count="$(grep -c -e "" <<< "${TEST_RESULTS[@]}")"
  if [ "$error_count" -gt 0 ]; then
    echo "Test suite $(printfc "$TEST_SUITE" "$CYAN") $(printfc "FAILED" "$RED"), $error_count failure(s)."
    return 1
  else
    echo "Test suite $(printfc "$TEST_SUITE" "$CYAN") $(printfc "SUCEEDED" "$GREEN")"
  fi
}

# Finalizes the current test suite, replays the failed tests if necessary.
# Uses: checkTestSuiteStatus, replayFailed
finalizeTestSuite() {
  checkTestSuiteStatus || { echo -e "\nReplaying the failed tests:"; replayFailed; return 1; }
}

# Replays all the failed tests to output the actual output and compare it with the expected one.
replayFailed() {
  local error_count actualResult unitTest
  error_count="$(grep -c -e "" <<< "${TEST_RESULTS[@]}")"
  if [ "$error_count" -gt 0 ]; then
    echo "Nothing to replay, last test suite '$TEST_SUITE' went well."
  fi

  for unitTest in "${TEST_RESULTS[@]}"; do
    if echo -e "$unitTest" | grepn -e ""; then
      local regex="^([^]+)([^]+)"
      [[ $unitTest =~ $regex ]]
      local method=${BASH_REMATCH[1]}
      local result=${BASH_REMATCH[2]}
      actualResult="$(eval "$method")"

      echo "Method $(printfc "$method" "$CYAN")"
      echo "Expected $(printfc "$result" "$GREEN")"
      echo "Got $(printfc "$actualResult" "$RED")"
    fi
  done
}
