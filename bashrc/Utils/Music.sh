#-------#
# Music #
#-------#

# These utilities work with a simple API hosted on cloud.restlet.com which I haven't open-sourced yet.

export MUSIC_FILE="$PRIVATE_TOOLING/music.json"

test -f "$MUSIC_FILE" || {
  colorize "Please type your API credentials in $MUSIC_FILE" "$RED"
  printf '{\n  "login": "",\n  "password": ""\n}\n' > "$MUSIC_FILE"
}

# Adds a new song in the list of songs I like. Songs can be passed via a '-' separated input or the named attributes below.
# Uses: params module, JSON module, $PRIVATE_TOOLING/music.json
# a: the artist's name
# n: the song's name
musicAdd() {
  local params artist name
  local paramsConfig='{"a": {"type": "string","hasValue": true, "isRequired": true}, "n": {"type": "string","hasValue": true, "isRequired": true}}'

   if grepn -e '-a' <<< "$@"; then
     params="$(setParams "$paramsConfig" "$@" || { return 1; })"
     artist="$(jsonGet '.a' <<< "$params")"
     name="$(jsonGet '.n' <<< "$params")"
   else
    artist="$(awk '-F [-]' '{print $1}' <<< "$@" | trim)"
    name="$(awk '-F [-]' '{print $2}' <<< "$@" | trim)"
   fi

  curl -sS -X POST \
    -u "$(jsonGet '.login' < "$MUSIC_FILE"):$(jsonGet '.password' < "$MUSIC_FILE")" \
    -H 'Content-Type:application/json' \
    -H 'Accept:application/json' \
    -d "{\"artist\": \"$artist\", \"name\": \"$name\"}" \
    'https://rsmymusic.apispark.net/v1/songs' \
    | jq '.'
    printf '\n'
}

# Displays the current list of songs I like, sorted by artist.
# Uses: $PRIVATE_TOOLING/music.json
musicRead() {
  local verbose='false'
  grepn -e '\-v' <<< "$*" && { verbose='true'; }

  local lines artist name id
  lines="$(\
    curl -sS \
    -u "$(jsonGet '.login' < "$MUSIC_FILE"):$(jsonGet '.password' < "$MUSIC_FILE")" \
    -H 'Accept:application/json' \
    'https://rsmymusic.apispark.net/v1/songs' \
    | jqcr '.[]' \
    | while read -r entry; do
      artist="$(jq -r '.artist' <<< "$entry")"
      name="$(jq -r '.name' <<< "$entry")"
      id="$(jq -r '.id' <<< "$entry")"

      printf '%s - %s' "$(printfcBold "$artist" "$BLUE")" "$(printfcBold "$name" "$GREEN")"

      if isTrue "$verbose"; then
        printfcBold ": $id\n" "$YELLOW"
      else
        printf '\n'
      fi
    done)"
  sort <<< "$lines"
}
