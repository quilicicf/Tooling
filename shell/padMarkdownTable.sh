#!/usr/bin/env bash

# Pipe a markdown table to this method to add a padding to all the cells.
# The padding is set to 30 but can be changed in method _padLine.
# Usage: source padMarkdownTable.sh; padMarkdownTable <<< "$markdownTableInVariable"
padMarkdownTable() {
  local table line header

  table="$(cat)"
  header="$(head -1 <<< "$table")"
  local onlyPipes="${header//[^|]/}"
  local pipesNumber="${#onlyPipes}"
  local columnsNumber=$(( pipesNumber - 1 ))

  shopt -s extglob
  while read -r line; do
    _padLine "$line" "$columnsNumber"
  done <<< "$table"
  shopt -u extglob
}

_padLine() {
  local line="$1"
  local columnsNumber="$2"
  local i fragment

  printf '|'
  for (( i=2; i<=(columnsNumber + 1); i++ )); do
    fragment=$(awk -F'|' "{print \$$i}" <<< "$line")
    local trimmedFragment=${fragment%%+([[:space:]])}
    printf '%-30s|' "$trimmedFragment"
  done
  printf '\n'
}
