# Parses the diff of a PR to find the hidden hideous System.out.println
@include "awkutils.awk"
BEGIN {
  gitFileName = "Tititatatoto" # current file name
  gitLine = 0 # current line in new file
  abnormalStuffCounter = 0

  print "\n"
  print "ABNORMAL STUFF FOUND IN THE PULL REQUEST"
  print "========================================"
}

match($0, /^diff \-\-git a\/((.+\/)*(\.?[^\.]+))(\.[a-zA-Z]+)? .*$/, m) { gitFileName = m[3]; if (m[4] != ".java") { gitFileName = m[1] }; } # entering new file
/^@@ \-[0-9]+,[0-9]+ \+[0-9]+,[0-9]+ @@.*$/ { gitLine = gitLineNumber($0); } # initializing line number

/^\+.*System\.out\.println.*$/ { abnormalStuffCounter++; gitPrettyPrint("System.out.println") }
/^\+.*TODO.*$/ { abnormalStuffCounter++; gitPrettyPrint("TODO") }
/^\+.*FIXME.*$/ { abnormalStuffCounter++; gitPrettyPrint("FIXME") }
/^\+.*Mock.*$/ { abnormalStuffCounter++; gitPrettyPrint("Mock") }
/^\+.*Dodelidou.*$/ { abnormalStuffCounter++; gitPrettyPrint("Dodelidou") }
/^\+.*\/cyp.*$/ { abnormalStuffCounter++; gitPrettyPrint("Absolute path") }

!NF || /^[^\-].*$/ { gitLine++ } # computing line number

END {
  print "========================================"

  if (abnormalStuffCounter > 0) {
    print colorRed() "There's abnormal stuff in your PR! \nBad boy."
  }
  else {
    print colorGreen() "Nothing seems abnormal in your PR! \nGood boy!"
  }

  print colorDefault()
}
