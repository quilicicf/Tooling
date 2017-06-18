###############
# JIRA macros #
###############

# Creates a snippet to generate a code entry in JIRA.
# Uses: json module, parameters module
# c: sets collapsible option
# n: sets line numbering
# l: sets the language
# t: sets the title
jiraCode() {
  local params language collapsible linenumbers
  local paramsConfig='{"l":{"type":"string","hasValue":true,"isRequired":false},"t":{"type":"string","hasValue":true,"isRequired":false},"c":{"type":"string","hasValue":false,"isRequired":false},"n":{"type":"string","hasValue":false,"isRequired":false}}'
  params="$(setParams "$paramsConfig" "$@" || { return 1; })"

  if isNotNull "$(jsonGet '.l' <<< "$params")"; then
    language="language=$(jsonGet '.l' <<< "$params")| "
  fi

  local title
  if isNotNull "$(jsonGet '.t' <<< "$params")"; then
    title="title=$(jsonGet '.t' <<< "$params")| "
  fi

  collapsible="collapse=$(jsonGet '.c' <<< "$params")| ";
  linenumbers="linenumbers=$(jsonGet '.n' <<< "$params")| ";
  local snippet="{code: $language$title$collapsible$linenumbers""theme=RDark"
  cb <<< "$snippet"
}
