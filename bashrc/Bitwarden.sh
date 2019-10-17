################
#   Bitwarden  #
################

# Unlocks bitwarden vault
_bwUnlock() {
  local sessionToken
  local tempFile='/tmp/bwUnlock.txt'

  bw unlock > "$tempFile"
  sessionToken="$(grep '\$ export BW_SESSION' < "$tempFile" | awk -F'"' '{print $2}')"
  export BW_SESSION="$sessionToken"
  rm "$tempFile" &> /dev/null
}

# Retrieves a TOTP from bitwarden and copies it to the clipboard
totp() {
  local search="${1?Missing search text}"

  if test -z "$BW_SESSION"; then
    _bwUnlock
  fi

  bw get totp "$search" | cbs
}
