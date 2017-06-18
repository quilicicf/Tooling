##############
# Parameters #
##############

_checkRequiredParams() {
  local paramsConfig="$1"
  shift

  local keys
  keys="$(_getKeys "$paramsConfig")"
  while read -r key; do
    if isTrue "$(jsonGet ".$key.isRequired" <<< "$paramsConfig")" > /dev/null; then
      if grepn -v -e "-$key" <<< "$@"; then
        echo "Missing required parameter -$key"
        return 1
      fi
      echo "" > /dev/null
    fi
  done <<< "$keys"
}

_checkHasNoValue() {
  if isTrue "$(jsonGet "$1" ".$2.hasValue")"; then
    echo "Missing value for parameter -$2"
    return 1
  fi
}

_getKeysForGetOpts() {
  local paramsConfig="$1"
  shift

  local keys
  keys="$(_getKeys "$paramsConfig")"
  echo -ne ":"
  while read -r key; do
    echo -n "$key"
    if isTrue "$(jsonGet ".$key.hasValue" <<< "$paramsConfig")" > /dev/null; then
      echo -n ":"
    fi
  done <<< "$keys"
}

_getKeys() {
  jqcr 'keys' <<< "$1" | jqcr '.[]'
}

_initializeBooleanParams() {
  local paramsConfig="$1"
  local keys key hasValue
  keys="$(_getKeys "$paramsConfig")"
  local params='{}'
  while read -r key; do
    hasValue="$(jsonGet ".$key.hasValue" <<< "$paramsConfig")"
    if isFalse "$hasValue"; then
      params="$(jsonSet ".$key" 'false' <<< "$params")"
    fi
  done <<< "$keys"
  echo "$params"
}

setParams() {
  local paramsConfig="$1"
  shift

  _checkRequiredParams "$paramsConfig" "$@" || { return 1; }
  local params keysForGetOpts optType optEnum
  params="$(_initializeBooleanParams "$paramsConfig")"
  keysForGetOpts="$(_getKeysForGetOpts "$paramsConfig")"

  OPTIND=1
  while getopts "$keysForGetOpts" opt; do
    if [[ "$opt" =~ [\?:]{1} ]]; then
      ((OPTIND--))
      echo "Missing value for parameter ${!OPTIND}"
      return 1
    else
      if [ -n "$OPTARG" ]; then
        optType="$(jqcr ".$opt.type" <<< "$paramsConfig")"
        optEnum="$(jqcr ".$opt.enum" <<< "$paramsConfig")"
        if _checkValue "$OPTARG" "$optType" "$optEnum" "$opt"; then
          params="$(jsonSet ".$opt" "$OPTARG" "$optType" <<< "$params")"
        else
          echo "Parameter -$opt must be of type $optType"
          return 1
        fi
      else
        _checkHasNoValue "$paramsConfig" "$opt" || { return 1; }
        params="$(jsonSet ".$opt" 'true' <<< "$params")"
      fi
    fi
  done

  echo "$params"
}

_checkValue() {
  local paramValue="$1"
  local paramType="$2"
  local paramEnum="$3"
  local paramName="$4"
  if [ "$paramType" = "int" ]; then
    if grepn -v -e "^[0-9][0-9]*$" <<< "$paramValue"; then
      echo "Parameter -$paramName must be of type $paramType"
      return 1
    fi
  fi

  if isNotNull "$paramEnum"; then
    jsonContains "$paramValue" <<< "$paramEnum" || { echo "Parameter -$paramName must be one of $paramEnum"; return 1; }
  fi
}

testParams() {
  initializeTestSuite
  echo "Check required parameters:"
  assertOk "_checkRequiredParams '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}' '-s'"
  assertNotOk "_checkRequiredParams '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}'" "Missing required parameter -s"
  assertEquals "_checkRequiredParams '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}'" "Missing required parameter -s"

  echo -e "\nCheck parameter values:"
  assertOk "_checkHasNoValue '{\"s\": {\"type\": \"string\", \"hasValue\": false, \"isRequired\": true}}' 's'"
  assertNotOk "_checkHasNoValue '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}' 's'"
  assertEquals "_checkHasNoValue '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}' 's'" "Missing value for parameter -s"

  echo -e "\nCheck parameter value:"
  assertOk "_checkValue 'toto' 'string' 'null' 's'"
  assertOk "_checkValue 'toto' '' 'null' 's'"
  assertNotOk "_checkValue 'toto' 'int' 'null' 's'"
  assertOk "_checkValue '123' 'int' 'null' 's'"
  assertNotOk "_checkValue '1.23' 'int' 'null' 's'"
  assertOk "_checkValue 'toto' 'string' '[\"toto\", \"tata\"]' 's'"
  assertNotOk "_checkValue 'titi' 'string' '[\"toto\", \"tata\"]' 's'"

  echo -e "\nsetParams"
  assertEquals "setParams '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": false}}' '-s' 'toto'" '{"s":"toto"}'
  assertNotOk "setParams '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}' '-s'"
  assertEquals "setParams '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}' '-s'" 'Missing value for parameter -s'
  assertNotOk "setParams '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}'"
  assertEquals "setParams '{\"s\": {\"type\": \"string\", \"hasValue\": true, \"isRequired\": true}}'" 'Missing required parameter -s'
  assertEquals "setParams '{\"s\": {\"hasValue\": false, \"isRequired\": false}}' '-s'" '{"s":true}'
  assertEquals "setParams '{\"s\": {\"hasValue\": false, \"isRequired\": false}}'" '{"s":false}'
  finalizeTestSuite
}
