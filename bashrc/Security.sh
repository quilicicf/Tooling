############
# Security #
############

# Audits the maven module described by ./pom.xml
auditMavenModule() {
  mvn org.sonatype.ossindex.maven:ossindex-maven-plugin:3.0.1:audit -Dossindex.fail=false
}
