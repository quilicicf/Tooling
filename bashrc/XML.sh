###############
#     XML     #
###############

# Evaluates an XPath expression against an XML document
# The XML document can be passed either:
# * with a file path, as second parameter
# * with raw content, piped
# In case the document contains an xmlns declaration, the XPath expression must 
# prefix fragments with ns. Ex: //ns:project/ns:modules/ns:module/text()
#
# $1: The XPath expression
# $2: (OPTIONAL) the file path to the XML document
xml() {
  local xpath="${1?Missing XPath expression}"

  local input
  test -t 0 && { 
    local filePath="${2?Missing XML path}"
    input="$(<"${filePath}")"
  }
  test -z "${input}" && { input="$(cat)"; }

  local regex='xmlns="(http(s)?://[^"]*)"'
  if [[ "${input}" =~ $regex ]]; then
    local xmlns="${BASH_REMATCH[1]}"

    1>&2 printf \
      'The XML has a namespace: %s\nPrefix your fragments with "ns:"\n' \
      "${xmlns}"
    xmlstarlet sel \
      -N "ns=${xmlns}" \
      --template \
      --value-of "${xpath}" \
      <<< "${input}"
  else
    xmlstarlet sel \
      --template \
      --value-of "${xpath}" \
      <<< "${input}"
  fi
}
