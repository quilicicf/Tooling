#----#
# Ls #
#----#

# Comprehensive ls
ll() {
  ls -lah
}

# Semi-comprehensive ls
l() {
  ls -a
}

# Shows hidden files
lh() {
  find . -maxdepth 1 -regex "^\..*"
}

# Tree-like ls
# Uses: tree
# $1: depth
lt() {
  if [ -z "$1" ]; then
    depth=2
  else
    depth="$1"
  fi
  tree -L "$depth"
}

# Cds then lss to the given repo
cdls() {
  cd "$1" || { echo "$1 does not exist or is not a repository"; return 1; }
  ls
}
