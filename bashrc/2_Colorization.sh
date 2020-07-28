########################
#     Colorization     #
########################

# For editors (i.e. meld)
export GTK_THEME='Adwaita:dark'

# For use in outputs (echo)
export BLACK='\e[0;30m'
export BLUE='\e[0;34m'
export GREEN='\e[0;32m'
export CYAN='\e[0;36m'
export RED='\e[0;31m'
export PURPLE='\e[0;35m'
export BROWN='\e[0;33m'
export LIGHTGRAY='\e[0;37m'
export DARKGRAY='\e[0;90m'
export LIGHTBLUE='\e[0;94m'
export LIGHTGREEN='\e[0;92m'
export LIGHTCYAN='\e[0;96m'
export LIGHTRED='\e[0;91m'
export LIGHTPURPLE='\e[0;95m'
export YELLOW='\e[0;33m'
export WHITE='\e[0;37m'
export DEFAULT='\e[0m'

export shellColors
shellColors=$(cat "$TOOLING/bash-prompt/colors")

#-------------------#
# Colorize commands #
#-------------------#

alias ls="ls --color=auto"
[[ "$TERM" != "dumb" ]] && { eval "$(dircolors -b)"; }

alias diff='colordiff'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias rgb2hex='printf "#%02x%02x%02x\n"'

export LESSOPEN="| /usr/bin/highlight %s --out-format truecolor --force --line-numbers --style andes"
export LESS='--RAW-CONTROL-CHARS' # Use colors for less, man, etc.
test -f ~/.config/less/termcap && { . "$_"; }

# grc.bashrc from https://github.com/garabik/grc/raw/master/grc.bashrc
test -s ~/.config/grc.bashrc && { source "$_"; }

#---------------------#
# Color manipulations #
#---------------------#

colorList() {
  echo "$shellColors" | awk -F '[ ]' '{ print $1 }'
}

colorReset() {
  echo "$DEFAULT"
}

# Gets the color code for the given color
# $1: -f for foreground, -b for background (default: foreground)
# $2: the color
# TODO: errors in parameters
colorGetCode() {
  if [ "$1" = "-f" ];then
    echo "$shellColors" | grep "fg_$2" | awk -F '[ ]' '{ print $2 }'
  else
    echo "$shellColors" | grep "bg_$2" | awk -F '[ ]' '{ print $2 }'
  fi
}

colorGet() {
  attribute="0"
  if [ "$1" = "bold" ]; then
    attribute="1"
  elif [ "$1" = "dim" ]; then
    attribute="2"
  elif [ "$1" = "hidden" ]; then
    attribute="8"
  fi

  foreground=$(echo "$shellColors" | grep "fg_$2" | awk -F '[ ]' '{ print $2 }')
  background=$(echo "$shellColors" | grep "bg_$3" | awk -F '[ ]' '{ print $2 }')

  echo "\[\e[$attribute;$foreground;$background""m\]"
}

colorSwitch() {
  printf "%s" "$(colorGet "$1" "$2" "$3")"
}

# printfcs the given output then switches back to default and outputs additional optional text.
# $1: the text to printfc
# $2: the color
# $3: the additional text
printfc() {
  printf "%b%b%b%b"  "$2" "$1" "$DEFAULT" "$3"
}

# printfcs the given output and boldifies it then switches back to default and outputs additional optional text.
# $1: the text to printfc
# $2: the color
# $3: the additional text
printfcBold() {
  printf "%b%b%b%b"  "${2/0;/1;}" "$1" "$DEFAULT" "$3"
}

# printfcs the text in the clipboard and opens the default browser to display the result for copy-paste into a rich text-editor.
# Uses: pandoc
# $1: the language of the code
printfcCode() {
  local languageOpt=${1?Missing language option at index 1}
  local language
  if [ "$languageOpt" = "-i" ]; then
    intChoose "$(cat "$BASHRC/syntaxHighlighting.json")"
    isNull "$INTERACTIVE_CHOICE" && { printf "Operation aborted\n"; return 0; }
    language="$INTERACTIVE_CHOICE"
  else
    language="$languageOpt"
  fi

  local content
  content="$(cb -o)"
  printf "\`\`\`%s\n%s\n\`\`\`" "$language" "$content" > /tmp/printfc.md
  pandoc -f "markdown" -t "html5" --self-contained  --highlight-style=pygments /tmp/printfc.md -o /tmp/printfc.html5
  xo /tmp/printfc.html5
  rm /tmp/printfc.md > /dev/null
}
