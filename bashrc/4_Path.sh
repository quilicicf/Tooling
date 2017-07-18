########
# Path #
########

# DSE
export PATH="$PATH:$WORK/dse/bin/"

# Node
export PATH="$PATH:/usr/bin/node"

# Maven
export PATH="$PATH:$MAVEN/bin"

# NVM
export NVM_DIR="$HOME/.nvm"
_configureNvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

_configureNvm

# rbenv
# export PATH="$HOME/.rbenv/bin:$PATH"
# eval "$(rbenv init -)"
