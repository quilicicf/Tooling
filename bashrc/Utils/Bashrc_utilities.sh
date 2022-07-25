#------------------#
# Bashrc utilities #
#------------------#

# Displays the f**g help, call without arguments to get help
rtfm() (
  cd "${HOME}/.bashrcDoc" || {
    printf 'Cannot cd to %s\n' "$_"
    return 1
  }

  if [[ -z "$1" ]]; then
    printf 'The commands are separated in categories. \n'
    printf 'Type: rtfm <category> to describe one or directly rtfm <command>. \n'
    printf 'Example: rtfm Git/Commits, rtfm up \n'
    printf 'Categories listed below\n\n'
    tree -L 3 -d | tr _ ' '

  else
    regex='^[A-Z].*'
    if [[ "$1" =~ $regex ]]; then
      folders="$(find "${BASHRC_DOC}" -name "*$1*" -type d)" || {
        printfc "Didn't find folder: $1\n" "${RED}"
        return 1
      }

      while read -r folder; do
        (
          cd "$folder" || {
            printf 'Cannot cd to %s\n' "$_"
            return 1
          }

          output="# Folder ${folder}\n"
          while read -r file; do
            local method
            method="$(< "$file")"
            output="${output}\n${method}\n"
          done <<< "$(find . -name "*.doc")"
        )
      done <<< "${folders}"

    else
      file="$(find . -name "$1.doc")"
      output="$(< "${file}")"
    fi

    displaymd "${output}"
  fi
)

# Opens the given bashrc file in the editor if it exists, $HOME/.bashrc otherwise
# Uses: $HOME, $TOOLING, $BASHRC, $EDITOR
# $1: the name or a part of the name of the searched file
# $2: the type of search, (values: -f, -c; default: -c)
wbashrc() (
  cd "${BASHRC}" || {
    printf 'Cannot cd to %s\n' "$_"
    return 1
  }
  searchType="$(readVar "-c" "$2" "-[fc]")"
  [[ -z "$1" ]] && {
    xo "${HOME}/.bashrc"
    return 0
  }

  [[ "${searchType}" = "-c" ]] && {
    files="$(pwd)/$(rg -l "^$1[^\(]*\(")"
    [[ "${files}" = "" ]] && { files="$(pwd)/$(ag -l "^alias\\s$1.*")"; }
    xo <<< "${files}"
  }

  [[ "${searchType}" = "-f" ]] && {
    find "${BASHRC}" -name "*$1*.sh" | xo
  }
)

_showShellCheckReport() (
  cd "${BASHRC}" || {
    printf 'Cannot cd to %s\n' "$_"
    return 1
  }
  git status -sb \
    | grep --invert-match "^##" \
    | grep --invert-match "^D" \
    | awk '{print $2}' \
    | grep ".*\.sh" \
    | while read -r file; do
      items="$(shellcheck -e SC2148 "$file" --format json | jqcr '.[]')"
      jqcr 'select(.level == "error")' <<< "${items}" | grepn -e 'level":"error"' && {
        shellcheck "${file}"
        return 1
      }
    done
)

# Builds the .bashrc file from the content of $BASHRC
# Uses: $BASHRC, $TOOLING, $JAVA
# $1: the optional log level, put -d to switch to debug (Optional; Values: -d)
brcbuild() (
  printfc "Assessing shell correctness with shellcheck\n" "${CYAN}"
  report="$(_showShellCheckReport)"
  if [[ -n "${report}" ]]; then
    printf '%s\n\n' "${report}"
    printfc "Shell validation failed, won't build" "${RED}"
    return 1
  fi

  BASHRC_UTILS="${TOOLING}/bashrcUtils"
  current_version="$(< "${BASHRC_UTILS}/version.txt")"
  jar="${BASHRC_UTILS}/target/bashrcUtils-${current_version}-jar-with-dependencies.jar"

  [[ -f "${jar}" ]] || (
    cd "${TOOLING}/bashrcUtils" || {
      printf 'Cannot cd to %s\n' "$_"
      return 1
    }
    printfc "Jar not found, building it for version ${current_version}\n" "${CYAN}"
    mvn 'assembly:assembly' --define "revision=${current_version}" || {
      printfc 'Could not generate the jar for bashrcUtils.' "${RED}"
      return 1
    }
  )

  printfc "Building with bashrcUtils version ${current_version}\n" "${CYAN}"
  javar "${jar}" -p "${BASHRC}" -s "${PRIVATE_TOOLING}/bashrc" build rtfm "$@"
)
