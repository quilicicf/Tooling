################
# Font awesome #
################

# Prints the characters that correspond to the search text.
# Uses: $TOOLING
# $1: the unicode
# $2: -n to avoid writing a line break after the character
faPrint() {
  local searchTerm="${1?Missing search term}"
  local iconsPath=~/.config/bashrc/fontawesome/icons.json
  "$TOOLING/bashrc/Fontawesome/print.js" "$iconsPath" "$searchTerm"
}

# Updates the list of icons from the github repository.
# Uses: yq, jq
faGet() {
  local folderPath=~/.config/bashrc/fontawesome
  test -d "$folderPath" || { mkdir -p "$folderPath"; }

  local iconsJsonFilePath="$folderPath/icons.json"

  curl 'https://raw.githubusercontent.com/FortAwesome/Font-Awesome/v4.7.0/src/icons.yml' \
    | yq --tojson eval \
    > "$iconsJsonFilePath"

}
