#########################
#   Java configuration  #
#########################

# Output the current system java version
javaGetJre() {
  update-alternatives --query java | grep Value | sed 's_^Value: __g' | sed 's_/bin/java__g'
}

export JRE_HOME JAVA_HOME
JRE_HOME="$(javaGetJre)"
JAVA_HOME="${JRE_HOME/\/jre/}"

# Sets the java version for the system
# $1: the new version (values: 7, 8)
javaSetVersion() {
  sudo update-alternatives --set java "/usr/lib/jvm/java-$1-oracle/jre/bin/java"
  JRE_HOME="$(javaGetJre)"
  JAVA_HOME="${JRE_HOME/\/jre/}"
}
