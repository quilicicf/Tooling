#-------------#
# Directories #
#-------------#

# Moves up in the directories by n steps
# $1: the number of steps
up() {
  local levels
  local path="."
  levels="$(readInt "1" "$1")"

  for ((i=1 ; i <= levels ; i++)); do
    path="$path"'/..'
  done

  cd "$path" || { printfc "CD '$path' failed" "$RED"; return 1; }
}

# Creates a directory and cds it
mkdirs() {
  local newDir="${1?Missing directory name}"
  mkdir "$newDir"
  cd "$newDir" || { printfc "CD '$newDir' failed" "$RED"; return 1; }
}

# Recursively computes the size of the given folder, displays it in a human-friendly fashion.
# Outputs the size of the current folder if none is provided.
# $1: the folder to get the size of
dirSize() {
  local folder
  folder="$(readVar '.' "$1")"
  du -hcs "$folder" | grep total | awk '{print $1}'
}
