##########
# Prompt #
##########

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
  PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'";$PROMPT_COMMAND"
  ;;
  *)
  ;;
esac

# Builds a beautiful PS1 using a CSV-generated config file
# Uses: $BASH_PROMPT_PATH, $TOOLING, ps1, ps1_config, splitAndGet, colorGetCode, colorSwitch, colorReset
promptBuild() {
  local config_path="$TOOLING/bash-prompt/ps1_config"
  local style foreground background cmd condition
  if [ -f "$config_path" ]; then
    local ps1=""
    local first="true"
    local before bebefore afafter after thething
    IFS=$'\n'

    while read -r line; do

      style=$(splitAndGet "$line" "," "1")
      foreground=$(splitAndGet "$line" "," "2")
      background=$(splitAndGet "$line" "," "3")
      cmd=$(splitAndGet "$line" "," "4")
      condition=$(splitAndGet "$line" "," "5")

      if [ "$first" == "true" ]; then
        first="false"
      else
        before="$(colorGetCode -b "$background")m\]"
      fi

      if [ "$condition" != "true" ]; then
        bebefore="\$(if $condition;then echo \""
        afafter="\"; else echo ""; fi;)"

      else
        bebefore=""
        afafter=""
      fi

      thething="$(colorSwitch "$style" "$foreground" "$background") $cmd "
      after="\[\e[0;$(colorGetCode -f "$background");"

      ps1="$ps1""$bebefore""$before""$thething""$after""$afafter"
    done < "$config_path"

    ps1="$ps1""49m\]$(colorReset)"
    echo "$ps1" > "$BASH_PROMPT_PATH/ps1"
  else
    echo "The config file $config_path was not found"
  fi
}

# Beautiful prompt
PROMPT_COMMAND="RET=\$?;$PROMPT_COMMAND"

# ALlows direnv to work. It loads .envrc when cding
direnv &> /dev/null && { eval "$(direnv hook bash)"; }

RET_VAL_COLOR="\$(if [[ \$RET -ne 0 ]]; then echo -ne \" \033[0;31m[\$RET]\033[0m \"; else echo -ne \"\"; fi;)"

if [ -f "$BASH_PROMPT_PATH/ps1" ]; then
  BASH_PROMPT=$(cat "$BASH_PROMPT_PATH/ps1")
else
  BASH_PROMPT="${RET_VAL_COLOR}\[\e[0;33m\]$(whoami)\[\e[0;36m\]:\w\[\e[0;35m\]\$(__git_ps1 \"(\%s)\")\n\[\e[0;32m\](\$(/bin/ls -1 | /usr/bin/wc -l | /bin/sed 's: ::g') files, \$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')b)\[\e[0;39m\]"
fi
[ -n "$PS1" ] && PS1="$BASH_PROMPT\n$FUNNY_PROMPT\[\e[0;39m\] "

printGitInformation() {
  local lock=''
  gbIsSafeBranch && { lock=''; }
  printf ' %s%s' "$lock" "$(echoc "$PS12")"
}
