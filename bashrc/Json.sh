########
# JSON #
########

# Poor attempt at creating a set of more understandable JSON parsing aliases as JQ tends to be complex to read.
# I'm currently looking at jqnode as a future replacement for this module.

# Gets all the attribute's values of the given JSON object.
# Uses: json module
# $1: the JSON object, can be piped
jsonValues() {
  local input keys
  [ -t 0 ] && { input="${1:?Missing input JSON at index 1}"; shift; }
  [ -z "$input" ] && { input="$(cat)"; }

  keys="$(jqcr 'keys' <<< "$input" | jqcr '.[]')"
  while read -r key; do
    jsonGet ".$key" <<< "$input"
  done <<< "$keys"
}

# Adds all the elements piped to the method in an empty array.
# $1: excludes, an array of elements than can't be in the created array
jsonArrayize() {
  local input
  input="$(cat)"

  [ -z "$input" ] && { printf '[]'; return 0; }

  local excludes="${1:-[]}"
  local array='[]'

  local item
  while read -r item; do
    jsonContains "$item" <<< "$excludes" || { array="$(jsonSet '.' "$item" "string" <<< "$array")"; }
  done <<< "$input"
  printf "%s" "$array"
}

# Formats json input.
# Uses: node, json module
# c: from clipboard to clipboard
# i: the number of spaces for indentation (default: 2)
jsonFormat() {
  local params input
  local paramsConfig='{"c": {"type": "string","hasValue": false, "isRequired": false}, "i": {"type": "string","hasValue": true, "isRequired": false}}'
  params="$(setParams "$paramsConfig" "$@" || { return 1; })"

  local format=', null, 2'
  jsonHas '.i' <<< "$params" && { format=", null, $(jsonGet '.i' <<< "$params")"; }

  if isTrue "$(jsonGet '.c' <<< "$params")"; then
    input="$(cb -o)"
    node -e "console.log(JSON.stringify($input$format));" | cb
  else
    input="$(cat)"
    node -e "console.log(JSON.stringify($input$format));"
  fi
}

# Adds an element to the given JSON object at the given path.
# Uses: jq
# $1: The JSON object to update
# $2: The path to the element to add
# $3: The element to add
# $4: The type of the element to add to add quotes around strings (optional)
jsonSet() {
  local input container_type variable_type length
  if [ -t 0 ]; then
    if [ -z "$1" ]; then
      input="{}"
    else
      input="$1"
    fi
    shift
  else
    input="$(cat)"
  fi

  [ -z  "$input" ] && { echo "No input"; return 1; }

  local path="${1:?Missing \'path\' at index 1}"
  container_type="$(jqcr "$path | type" <<< "${input:? Missing \'input\' at index 1}")"
  variable_type="$(readVar "unknown" "$3")"

  local variable_value="${2:? Missing \'value\' at index 2}"
  if [ "$variable_type" = "string" ]; then
    variable_value="\"$variable_value\""
  fi

  if [ "$container_type" = "array" ]; then
    length="$(jqcr "$path | length" <<< "$input")"
    input="$(jqcr "$path[$length] = $variable_value" <<< "$input")"
  else
    input="$(jqcr "$path = $variable_value" <<< "$input")"
  fi
  echo "$input"
}


# Deletes the element at the given path from the given JSON object.
# Uses: jq
# $1: The JSON object to update
# $2: The path to the element to delete
jsonDelete() {
  echo "$1" | jq -c "del($2)"
}

# Determines if the given JSON object has an attribute at the given path.
# Returns 0 if true, 1 if false. In verbose mode, displays true or false.
# Uses: jq
# $1: The JSON object to check
# $2: The path to the element to check
# $3: Put -v here for verbose mode (optional)
jsonHas() {
  local input
  [ -t 0 ] && { input="${1:?Missing input JSON at index 1}"; shift; }
  [ -z "$input" ] && { input="$(cat)"; }
  local full_path="$1"

  local verbose="false"
  [ "$2" = "-v" ] && { verbose="true"; }

  local regex="^(.*?)(\.([^\.]+))$"
  [[ $full_path =~ $regex ]] || { echo "The path must follow the regex: $regex"; return 1; }
  local path=${BASH_REMATCH[1]}
  local lastKey=${BASH_REMATCH[3]}

  [ "$path" != "" ] && { input="$(jsonGet "$input" "$path" -r)"; }

  if isTrue "$(jqcr "has(\"$lastKey\")" <<< "$input")"; then
    if isTrue "$verbose"; then
      echo "true"
    fi
  else
    isTrue "$verbose"  && { echo "false"; }
    return 1
  fi
}

# Gets the element at the given path from the given JSON object.
# Uses: jqcr
# $1: The JSON object
# $2: The path to the element
jsonGet() {
  local input
  [ -t 0 ] && { input="${1:?Missing input JSON at index 1}"; shift; }
  [ -z "$input" ] && { input="$(cat)"; }
  local path="$1"

  if [ "$path" = "." ] || [ -z "$path" ]; then
    echo "$input"
    return 0
  fi

  echo "$input" | jqcr "$path"
}

jsonContains() {
  local input
  [ -t 0 ] && { input="${1:?Missing input JSON at index 1}"; shift; }
  [ -z "$input" ] && { input="$(cat)"; }
  local value=${1?Missing value}

  local item
  while read -r item; do
    grepn -x -e "$value" <<< "$item" && { return 0; }
  done <<< "$(jqcr '.[]' <<< "$input")"

  return 1
}

jsonSearch() {
  local input input_type
  if [ -t 0 ]; then
    if [ -z "$1" ]; then
      input="{}"
    else
      input="$1"
    fi
    shift
  else
    input="$(cat)"
  fi

  local key="$1"
  local value="$2"

  input_type="$(jqcr 'type' <<< "$input")"
  if grepn -v -e "array" <<< "$input_type"; then
    echo "Cannot search a non-array, the input is of type '$input_type'"
    return 1
  fi

  echo "$input" | jqcr '.[]' | jqcr "select($key == $value)"

}

testJson() {
  initializeTestSuite
  echo "JSON get"
  assertEquals "jsonGet '{\"name\": \"toto\"}' '.name'" "toto"
  assertEquals "jsonGet '{\"address\": { \"planet\": \"Endor\"}}' '.address.planet'" "Endor"
  assertEquals "jsonGet '.name' <<< '{\"name\": \"toto\"}'" "toto"
  assertEquals "jsonGet '.address.planet' <<< '{\"address\": { \"planet\": \"Endor\"}}'" "Endor"

  echo -e "\nJSON delete"
  assertEquals "jsonDelete '{\"name\": \"toto\"}' '.name'" "{}"
  assertEquals "jsonDelete '{\"address\": { \"planet\": \"Endor\"}}' '.address.planet'" "{\"address\":{}}"

  echo -e "\nJSON set"
  assertEquals "jsonSet '.name' 'toto' 'string' <<< '{}'" "{\"name\":\"toto\"}"
  assertEquals "jsonSet '.age' '123' 'int' <<< '{}'" "{\"age\":123}"
  assertEquals "jsonSet '.' 'Toto' 'string' <<< '[]'" "[\"Toto\"]"
  assertEquals "jsonSet '{}' '.b' '2' | jsonSet '.a' '4'" "{\"b\":2,\"a\":4}"
  assertEquals "jsonSet '{}' '.name' 'toto' 'string'" "{\"name\":\"toto\"}"
  assertEquals "jsonSet '{\"address\": {}}' '.address.planet' 'Endor' 'string'" "{\"address\":{\"planet\":\"Endor\"}}"

  echo -e "\nJSON has"
  assertEquals "jsonHas '{\"name\": \"toto\"}' '.name' -v" "true"
  assertEquals "jsonHas '{\"name\": \"toto\"}' '.nem' -v" "false"
  assertOk "jsonHas '{\"name\": \"toto\"}' '.name'"
  assertNotOk "jsonHas '{\"name\": \"toto\"}' '.nem'"
  assertOk "jsonHas '.name' <<< '{\"name\": \"toto\"}'"
  assertEquals "jsonHas '{\"address\": { \"planet\": \"Endor\"}}' '.address.planet' -v" "true"
  assertEquals "jsonHas '{\"address\": { \"planet\": \"Endor\"}}' '.address.plumet' -v" "false"

  echo -e "\nJSON search"
  assertEquals "jsonSearch '{}' '.name' '\"toto\"'" "Cannot search a non-array, the input is of type 'object'"
  assertEquals "jsonSearch '[{\"name\": \"toto\"}, {\"name\": \"tata\"}]' '.name' '\"toto\"'" "{\"name\":\"toto\"}"
  assertEquals "jsonSearch '[{\"address\": {\"planet\": \"Endor\"}}]' '.address.planet' '\"Endor\"'" "{\"address\":{\"planet\":\"Endor\"}}"

  echo -e "\nJSON values"
  assertEquals "jsonValues '{\"name\": \"toto\"}'" "toto"

  printf "\nJSON contains\n"
  local search='titi'
  local contains='["titi", "toto"]'
  local noContains='[]'
  assertOk "jsonContains '$search' <<< '$contains'"
  assertNotOk "jsonContains '$search' <<< '$noContains'"

  printf "\nJSON arrayize\n"
  local excludes='["titi"]'
  assertEquals "printf 'titi\ntata\ntoto' | jsonArrayize" '["titi","tata","toto"]'
  assertEquals "printf 'titi\ntata\ntoto' | jsonArrayize '$excludes'" '["tata","toto"]'
  assertEquals "printf '' | jsonArrayize" '[]'
  assertEquals "printf '' | jsonArrayize '$excludes'" '[]'

  finalizeTestSuite
}
