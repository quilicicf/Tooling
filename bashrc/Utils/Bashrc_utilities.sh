#------------------#
# Bashrc utilities #
#------------------#

# Displays the f**g help, call without arguments to get help
rtfm() {
  pushd "$HOME/.bashrcDoc"
  if [ -z "$1" ]; then
    echo -e "The commands are separated in categories. \nType: rtfm <category> to describe one or directly rtfm <command>. \nExample: rtfm Git/Commits, rtfm up \nCategories listed below\n\n"
    tree -L 3 -d | tr _ ' '
  else
    local regex='^[A-Z].*'
    local output
    local file
    if [[ "$1" =~ $regex ]]; then
      local folders
      folders="$(find "$BASHRC_DOC" -name "*$1*" -type d)" || {
        printfc "Didn't find folder: $1\n" "$RED"
        return 1
      }

      while read -r folder; do
        pushd "$folder"
        output="# Folder $folder\n"
        while read -r file; do
          local method
          method="$(< "$file")"
          output="$output\n$method\n"
        done <<< "$(find . -name "*.doc")"
        popd
      done <<< "$folders"
    else
      file="$(find . -name "$1.doc")"
      output="$(< "$file")"
    fi
    displaymd "$output"
  fi
  popd
}

# Opens the given bashrc file in the editor if it exists, $HOME/.bashrc otherwise
# Uses: $HOME, $TOOLING, $BASHRC, $EDITOR
# $1: the name or a part of the name of the searched file
# $2: the type of search, (values: -f, -c; default: -c)
wbashrc() {
  pushd "$BASHRC"
  local searchType
  searchType=$(readVar "-c" "$2" "-[fc]")
  [ -z "$1" ] && { xo "$HOME/.bashrc"; return 0; }

  local file
  [ "$searchType" = "-c" ] && {
    files="$(pwd)/$(ag -l "^$1[^\(]*\(")"
    [ "$files" = "" ] && { files="$(pwd)/$(ag -l "^alias\\s$1.*")"; }
    xo <<< "$files"
  }

  [ "$searchType" = "-f" ] && {
    find "$BASHRC" -name "*$1*.sh" | xo
  }
  popd
}

_showShellCheckReport() {
  pushd "$BASHRC"
  git status -sb \
  | egrep -v "^##" \
  | egrep -v "^D" \
  | awk '{print $2}' \
  | egrep ".*\.sh" \
  | while read -r file; do
    local items
    items="$(shellcheck -e SC2148 "$file" --format json | jqcr '.[]')"
    jqcr 'select(.level == "error")' <<< "$items" | grepn -e 'level":"error"' && {
      shellcheck "$file"
      return 1
    }
  done
  popd
}

# Builds the .bashrc file from the content of $BASHRC
# Uses: $BASHRC, $TOOLING, $JAVA
# $1: the optional log level, put -d to switch to debug (Optional; Values: -d)
brcbuild() {
  printfc "Assessing shell correctness with shellcheck\n" "$CYAN"
  local report
  report="$(_showShellCheckReport)"
  if [ -n "$report" ]; then
    printf '%s\n\n' "$report"
    printfc "Shell validation failed, won't build" "$RED"
    return 1
  fi

  local BASHRC_UTILS="$TOOLING/bashrcUtils"
  local current_version
  current_version="$(<"$BASHRC_UTILS/version.txt")"
  local jar="$BASHRC_UTILS/target/bashrcUtils-$current_version-jar-with-dependencies.jar"

  [ -f "$jar" ] || {
    pushd "$TOOLING/bashrcUtils"
    printfc "Jar not found, building it for version $current_version\n" "$CYAN"
    mvn clean assembly:assembly "-Drevision=$current_version" || {
      printfc 'Could not generate the jar for bashrcUtils.' "$RED"
      return 1
    }
    popd
  }

  printfc "Building with bashrcUtils version $current_version\n" "$CYAN"
  javar "$jar" -p "$BASHRC" build rtfm "$@"
}
