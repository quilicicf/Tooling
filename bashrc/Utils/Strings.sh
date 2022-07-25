#---------#
# Strings #
#---------#

# Formats a string with variables
# Usage: format 'Hi, I\'m $name' '{"name": "Toto"}' => 'Hi, I'm Toto'
# Uses: JSON module
# $1: the string to format
# $2: the variables in JSON
format() (
  text=${1?Missing input text at index 1}
  config=${2?Missing config at index 2}

  while read -r key; do
    value="$(jq -r ".${key}" <<< "${config}")"
    text=${text//\$${key}/${value}}
  done <<< "$(jq -r 'keys | .[]' <<< "${config}")"
  printf '%s\n' "${text}"
)

# Joins the input with the given separator
# Uses: parameters module
# $1: separator
join() (
  separator="${1?Missing separator at index 1}"
  shift
  printf "%b" "$(perl -E 'say join(shift, @ARGV)' "${separator}" "$@")"
)

# Trims the given string
trim() (
  [[ -t 0 ]] && { toTrim="$*"; }
  [[ -z "${toTrim}" ]] && { toTrim="$(cat)"; }

  # note: the brackets in each of the following two lines contain one space
  # and one tab
  until
    trimmed="${toTrim#[   ]}"
    [[ "${trimmed}" = "${toTrim}" ]]
  do toTrim="${trimmed}"; done

  until
    trimmed="${toTrim%[   ]}"
    [[ "${trimmed}" = "${toTrim}" ]]
  do toTrim="${trimmed}"; done
  printf '%s\n' "${toTrim}"
)

uuid4() (
  uuid -v 4
)

# Creates a UUID and only returns its first part
smallUuid() (
  uuid -v 4 | awk -F- '{print $1}'
)

# Creates a date in ISO 8601
dateISO() (
  dateWithNanoSeconds="$(date +"%Y-%m-%dT%H:%M:%S.%N%:z")"
  printf '%s%s\n' "${dateWithNanoSeconds:0:23}" "${dateWithNanoSeconds:29}"
)

# Jenkins-like dates: 20181231120155
dateAllNumbers() (
  date +"%Y%m%d%H%M%S"
)

# Transforms bytes number to human-readable size
toHumanDiskSize() (
  numfmt --to=iec-i --suffix=B --padding=7 "$(cat)"
)
