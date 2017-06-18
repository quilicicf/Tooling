################
# Font awesome #
################

# FIXME: Broken ATM!

# Displays the fontawesome icons corresponding to the provided search word.
# Uses: y2j, jq, $FORGE
# $1: the search word
# $2: -s to search in strict mode
faGet() {
  local input="$1"
  local strict icons_file
  strict="$(readVar "" "$2")"
  icons_file="$(find "$TOOLING/tmp" -name "fa_*_icons.json")"

  if [ "$strict" = "-s" ]; then
    jqcr < "$icons_file" ".icons" \
    | jsonSearch ".id" "\"$input\"" \
    | jqcr '.unicode' \
    | faPrintChar ""

  else
    jqcr ".icons[]" < "$icons_file" | while read -r icon; do
      if grepn "$input" <<< "$(jqcr '.id' <<< "$icon")"; then
        jqcr ".unicode" <<< "$icon" | faPrintChar -n
      fi
    done
    printf "\n"
  fi
}

# Prints a character from its unicode.
# $1: the unicode
# $2: -n to avoid writing a line break after the character
faPrintChar() {
  local input
  [ -t 0 ] && { input="${1:?Missing input unicode}"; shift; }
  [ -z "$input" ] && { input="$(cat)"; }

  if [ "$1" = "-n" ]; then
    echo -ne "\u$input  "
  else
    echo -e "\u$input"
  fi
}

# Updates the list of icons from the github repository.
# Uses: git, git, $TOOLING, $FORGE/Font-Awesome, y2j
faUpdate() {
  pushd "$TOOLING/tmp"
  local current_file last_tag
  current_file="$(find . -name "fa_*_icons.json")"
  if [ -n "$current_file" ]; then
    rm "$current_file"
  fi
  popd

  pushd "$FORGE/Font-Awesome"
  git fetch origin
  last_tag="$(git tag | sort | tail -1)"

  git checkout "$last_tag"
  y2j < "src/icons.yml" > "$TOOLING/tmp/fa_$last_tag""_icons.json"
  popb
  popd
}
