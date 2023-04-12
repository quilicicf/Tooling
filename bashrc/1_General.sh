#######################
# Auto-generated crap #
#######################

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]]; then
  debian_chroot="$(cat /etc/debian_chroot)"
fi

##############################
#  Quiet pushd, popd & grep  #
##############################

pushd() {
  command pushd "$@" > /dev/null
}

popd() {
  command popd > /dev/null
}

grepn() {
  grep -q -s "$@"
}

###################
#     Log mode    #
###################

export LOG_MODE_FILE='/tmp/log.mode'

# Adds file log.mode in /tmp. It's used elsewhere to determine if the bashrc should be verbose or not.
logModeOn() {
  printf 'log:on' > "$LOG_MODE_FILE"
}

# Removes file log.mode in /tmp. It's used elsewhere to determine if the bashrc should be verbose or not.
logModeOff() {
  rm "$LOG_MODE_FILE"
}

# Returns 0 if the bashrc is in log mode, 1 otherwise.
isLogModeOn() {
  test -f "$LOG_MODE_FILE"
}

########################
#     Terminal look    #
########################

export HISTFILESIZE=20000
export HISTSIZE=10000
shopt -s histappend
shopt -s cmdhist
HISTCONTROL=ignoredups
shopt -s checkwinsize


###############
#     ASDF    #
###############

export ASDF_DIR=~/.asdf
test -s "$ASDF_DIR/asdf.sh" && { source "$_"; }
test -s "$ASDF_DIR/completions/asdf.bash" && { source "$_"; }

test -s "$(asdf which mvnd)-bash-completion.bash" && { source "$_"; }
if deno --help &> /dev/null; then
  source <(deno completions bash)
fi

############
# WHATEVER #
############

installFzf() {
  fzfBinPath="$(asdf which fzf)"
  test -s "${fzfBinPath%/bin/fzf}/shell/completion.bash" && { source "$_"; }
  _fzf_setup_completion path 'micro' 'xo' 'cbs' 'bash'

  local colors=(
    '--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9'
    '--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9'
    '--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6'
    '--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
  )
  export FZF_DEFAULT_OPTS="${colors[*]}"
}

installFzf

# Parses a CLI's help and greps the documentation for 
# one of its parameters out of it.
manFlag() (
  command="${1?Missing command}"
  param="${2?Missing parameter name}"

  if [[ "${#param}" -eq '1' ]]; then
    search="^[ ]*\-${param}"
  else
    search="^[ ]*\-\-${param}"
  fi

  if man "${command}" 2> /dev/null | grep --silent "${search}"; then
    man "${command}" | grep "${search}" --after 5
    
  elif eval "${command} --help" 2> /dev/null | grep --silent "${search}"; then
    eval "${command} --help" | grep "${search}" --after 5

  elif "${command} help" 2> /dev/null | grep --silent "${search}"; then
    eval "${command} help" | grep "${search}" --after 5
    
  else
    printf 'Could not find help using: ["%s", "%s", "%s" ]\n' \
      "man ${command}" "${command} --help" "${command} help"
    return 1
  fi
)

emo() {
  local emoji="${1?Missing input}"
  cbs <<< "$emoji"
}
