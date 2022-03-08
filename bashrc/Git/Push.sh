#------#
# Push #
#------#

# Resets, hard
grsh() {
  git reset --hard
}

# Deletes all untracked added files/folders
# Uses: gstu
grmh() {
  local line regex item
  gstu | while read -r line; do
    regex='^\?\?'
    if [[ "$line" =~ $regex ]]; then
      item="$(echo "$line" | awk '{ print $2 }')"
      if [ -f "$item" ]; then
        echo "Removing file $item"
        rm "$item" > /dev/null
      fi

      if [ -d "$item" ]; then
        echo "Removing folder $item"
        rm -rf "$item" > /dev/null
      fi
    fi
  done
}
