########
# Path #
########

# DSE
export PATH="$PATH:$WORK/dse/bin/"

# MongoDB
export PATH="$WORK/mongodb/bin:$PATH"

# Maven
export PATH="$PATH:$MAVEN/bin"

# Go
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Java
java -version &> /dev/null && {
  export JAVA_HOME
  JAVA_HOME="$(
    java -XshowSettings:properties -version 2>&1 \
      | grep 'java.home' \
      | awk -F '=' '{print $2}' \
      | tr -d '[[:blank:]]'
  )"
}
