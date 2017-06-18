###################
# General purpose #
###################

# Removes blank, "+" and "-" characters from the left-hand side of the given string
function ltrim(s) {
  sub(/^[ \t\+\-]+/, "", s);
  return s;
}

# Gets last segment of a given path
function getLastPathSegment(s) {
  sub(/^.*\//, "", s);
  return s;
}

# Removes the extension from the given file name
function removeFileExtension(s) {
  gsub(/\.[a-z]+/, "", s);
  return s;
}

function getFileName(s) {
  return removeFileExtension(getLastPathSegment(s));
}

#####################
#      Colors       #
#####################

function colorGreen() {
  return "\033[0;32m";
}

function colorPurple() {
  return "\033[0;35m";
}
function colorDefault() {
  return "\033[0;39m";
}
function colorRed() {
  return "\033[0;31m";
}
function colorYellow() {
  return "\033[0;33m";
}
function colorCyan() {
  return "\033[0;36m";
}

#####################
# Git diff specific #
#####################

# Given current found item, displays its file, line number and trimmed line content
function gitPrettyPrint(s) {
  print "Found a " s " in file\n\t" colorCyan() gitFileName "\t" colorPurple() gitLine "\t" colorYellow() ltrim($0) colorDefault() "\n"
}

# Retrieves the line number from the git diff
# Ex: gitLineNumber("@@ -233,7 +233,7 @@") returns 233
function gitLineNumber(s) {
  sub(/^@@ \-[0-9]+,[0-9]+ \+/, "", s);
  sub(/,[0-9]+ @@.*$/, "", s);
  return s
}
