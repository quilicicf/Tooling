#---------#
# Seqdiag #
#---------#

# Watches for files named *.diag in the given directory (recursive) and generates the
# corresponding PNG file.
# $1: the folder to watch (Default: pwd)
# shellcheck disable=SC2034
seqWatch() {
  local folder="$1"

  [[ -n "$folder" ]] || {
    printfc 'Folder not defined, it was set to pwd\n' "$YELLOW"
    folder="$(pwd)";
  }

  inotifywait -rm "$folder" -e close_write |
  while read path action file; do
    if [[ "$file" =~ .*\.diag$ ]]; then
      seqdiag "$path$file" --no-transparency -a
    fi
  done
}

# Inits a seqdiag file with the preferences defined in seqdiag.init.
# Uses: $TOOLING
# $1: the file to be created (absolute path)
seqInit() {
  local filePath="${1?Missing path to file}"

  mkdir -p "$(dirname "$filePath")"
  cp "$TOOLING/bashrc/Utils/seqdiag.init" "$(basename "$filePath")"
}
