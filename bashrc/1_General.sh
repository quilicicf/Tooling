#######################
# Auto-generated crap #
#######################

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
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
