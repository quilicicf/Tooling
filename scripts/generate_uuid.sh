#!/usr/bin/env bash

# Generates a UUID and copies it to the clipboard.
# Used in intelliJ external tools.
main() {
  printf '%s' "$(uuid)" | xclip -sel clipboard
}

main "$@"
