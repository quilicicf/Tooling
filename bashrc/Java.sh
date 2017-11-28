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
javaSetVersion() {
  sudo update-alternatives --config java
  JRE_HOME="$(javaGetJre)"
  JAVA_HOME="${JRE_HOME/\/jre/}"
}
