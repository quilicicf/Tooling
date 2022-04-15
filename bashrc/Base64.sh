###############################
# Base 64 non-moronic aliases #
###############################

b64d() (
  [[ -t 0 ]] && { 
    toDecode="$*"
  }
  [[ -z "${toDecode}" ]] && {
    toDecode="$(cat)"
  }

  result="$(printf '%s' "${toDecode}" | base64 -d 2> /dev/null)"
  [[ "$?" -ne '0' ]] && {
    printf '[WARNING] The input is missing some padding\n' 1>&2
  }
  printf '%s' "${result}"
)

b64e() (
  [[ -t 0 ]] && { 
    toEncode="$*"
  }
  [[ -z "${toEncode}" ]] && {
    toEncode="$(cat)"
  }

  printf '%s' "${toEncode}" | base64
)
