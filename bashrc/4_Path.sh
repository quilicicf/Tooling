########
# Path #
########

# DSE
export PATH="$PATH:$WORK/dse/bin/"

# Node
export PATH="$PATH:/usr/bin/node"

# Maven
export PATH="$PATH:$MAVEN/bin"

# NPM
_configureNpm() {
  local NODE_MODULES="$HOME/.npm"
  local NPM_PACKAGES="$HOME/.npm-global/bin"
  export NPM_CONFIG_PREFIX="$HOME/.npm-global"
  export PATH=$PATH:$HOME/bin:$NODE_MODULES:$NPM_PACKAGES
}
_configureNpm

# rbenv
# export PATH="$HOME/.rbenv/bin:$PATH"
# eval "$(rbenv init -)"
