################
# Font awesome #
################

# FIXME: Broken ATM!

# Displays the fontawesome icons corresponding to the provided search word.
# Uses: y2j, jq, $FORGE
# $1: the search word
# $2: -s to search in strict mode
# faSearch() {
  # local input="$1"
  # local strict icons_file
  # strict="$(readVar "" "$2")"
  # icons_file="$(find "$TOOLING/tmp" -name "fa_*_icons.json")"
  #
  # if [ "$strict" = "-s" ]; then
  #   jqcr < "$icons_file" ".icons" \
  #   | jsonSearch ".id" "\"$input\"" \
  #   | jqcr '.unicode' \
  #   | faPrintChar ""
  #
  # else
  #   jqcr ".icons[]" < "$icons_file" | while read -r icon; do
  #     if grepn "$input" <<< "$(jqcr '.id' <<< "$icon")"; then
  #       jqcr ".unicode" <<< "$icon" | faPrintChar -n
  #     fi
  #   done
  #   printf "\n"
  # fi
# }

# Prints a character from its unicode.
# $1: the unicode
# $2: -n to avoid writing a line break after the character
faPrint() {
  local searchTerm="${1?Missing search term}"
  local iconsPath=~/.config/bashrc/fontawesome/icons.json
  ./print.js "$iconsPath" "$searchTerm"
}

# Updates the list of icons from the github repository.
# Uses: yq, jq
faGet() {
  local folderPath=~/.config/bashrc/fontawesome
  if ! test -d "$folderPath"; then mkdir -p "$folderPath"; fi

  local iconsJsonFilePath="$folderPath/icons.json"

  curl 'https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/js-packages/%40fortawesome/fontawesome-free/metadata/icons.yml' \
    | yq read - --tojson \
    | jq '.' \
    > "$iconsJsonFilePath"

}
