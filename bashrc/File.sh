############
#   Files  #
############

# Creates a temporary executable script in /tmp, chx it and return the path
touchx() {
  local filePath
  filePath="$(mktemp -t XXXXX.sh)"
  chmod +x "$filePath"
  printf '%s' "$filePath"
}
