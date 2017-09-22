########################
#   Git configuration  #
########################

if test -f "$FORGE/github/quilicicf/bash-git-prompt/gitprompt.sh"; then
  . "$_";
  export GIT_PROMPT_THEME="Splendid";
  export GIT_PS1_SHOWDIRTYSTATE=true
  export GIT_PS1_SHOWUNTRACKEDFILES=true
  export GIT_PS1_SHOWUPSTREAM=verbose
elif isLogModeOn; then
  colorize "Please clone quilicicf/bash-git-prompt in $FORGE and switch to branch master_adjusted, otherwise the prompt will be broken." "$RED"
fi

test -f "$FORGE/bash-git-prompt/git-prompt-help.sh" && . "$_"

if test -f "$FORGE/github/git/git/contrib/completion/git-completion.bash"; then
  . "$_"
elif isLogModeOn; then
  colorize "Please clone git/git in $FORGE, otherwise, git completion and git prompt will be broken." "$RED"
fi
test -f "$FORGE/git/contrib/completion/git-prompt.sh" && . "$_"

# Simple branch name without remote and state
git_branch_simple() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

#####################
# Gut configuration #
#####################

# Installation of Gut scripts, see https://github.com/quilicicf/Gut/blob/master/specs/specs.md#shell-features
# If the link is broken, you probably want to read the README again https://github.com/quilicicf/Gut/blob/master/README.md
installGutScripts() {
  local script
  test -d ~/.config/gut && {
    while read script; do
      . "$script"
    done <<< "$(find ~/.config/gut -name '*.sh')"
  }
}
installGutScripts
