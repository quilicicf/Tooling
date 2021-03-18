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

# Remove CR in a file
crlf2Lf() {
  local file="${1?Missing file to update}"
  [[ -f "$file" ]] || {
    printf 'File %s does not exist\n' "$file"
    return 1
  }
  
  local content
  content="$(<"$file")"
  printf '%s' "${content//$'\r'/}" > "$file"
}
