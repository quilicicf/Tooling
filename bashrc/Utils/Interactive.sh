###############
# Interactive #
###############

export INTERACTIVE_CHOICE=''

# Outputs each element of the input as a numbered list element if it contains more than one element.
# Uses: join
_intPrintChoices() (
  [[ -t 0 ]] && {
    input="${1?Missing JSON input at index 1}"
    shift
  }
  [[ -z "$input" ]] && { input="$(cat)"; }

  labels="$(jqcr '.[] | .label' <<< "${input}")"

  if isNull "${labels}"; then
    return 1
  fi

  count=1
  choices=()
  while read -r choice; do
    choices+=("${count}/ ${choice}")
    ((count++))
  done <<< "${labels}"

  join "\n" "${choices[@]}"
  printf '\n'
)

# Utility method to make user think twice about doing something. Sets a "sure" variable to true or false
intConfirm() (
  printf "%b\n" "$1"
  select yn in "Yessssssssir" "Nopenopenope"; do
    case $yn in
      Yessssssssir) return 0 ;;
      Nopenopenope) return 1 ;;
    esac
  done
)

#
# Uses: intPrintChoices
intChoose() (
  [[ -t 0 ]] && {
    input="${1:?Missing JSON input at index 1}"
    shift
  }
  [[ -z "$input" ]] && { input="$(cat)"; }

  size="$(jqcr 'length' <<< "${input}")"
  if [ "${size}" = 0 ]; then
    return 1
  elif [ "${size}" = 1 ]; then
    INTERACTIVE_CHOICE=$(jsonGet '.[0].value' <<< "${input}")
  else
    printf "Found multiple choices:\n"
    _intPrintChoices "${input}"
    while read -rp "Choose one element by its number ('q' to quit): " answer; do
      [[ "${answer}" = "q" ]] && {
        INTERACTIVE_CHOICE='null'
        return 0
      }

      ((answer--))
      choice=$(jsonGet ".[${answer}].value" <<< "${input}")
      if isNull "${choice}"; then
        printf 'Bad choice, must be between 1 & %s !\n' "${size}"

      else
        INTERACTIVE_CHOICE="${choice}"
        return 0

      fi
    done
  fi
)
