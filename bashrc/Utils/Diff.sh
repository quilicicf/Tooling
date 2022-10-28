#-------#
# Diffs #
#-------#

export W1="${TOOLING}/diff/1.diff"
export W2="${TOOLING}/diff/2.diff"

# Displays diff between the files 1 & 2
# Uses: meld, $TOOLING/1.diff file, $TOOLING/2.diff file
mydiff() {
  meld "${TOOLING}/diff/1.diff" "${TOOLING}/diff/2.diff" &
  disown
}

# Opens file 1 in favorite editor
# Uses: xo, $TOOLING/diff/1.diff file
w1() {
  _openOrCreate "${W1}"
}

# Writes the content of the clipboard to 1.diff
# Uses: $W1, cbo
cbo1() {
  [[ -f "${W1}" ]] || { touch "${W1}"; }
  cbo > "${W1}"
}

# Opens file 2 in favorite editor
# Uses: $EDITOR, $TOOLING/diff/2.diff file
w2() {
  _openOrCreate "${W2}"
}

# Writes the content of the clipboard to 2.diff
# Uses: $W2, cbo
cbo2() {
  [[ -f "${W2}" ]] || { touch "${W2}"; }
  cbo > "${W2}"
}

_openOrCreate() (
  path="${1?Missing file path}"
  [[ -f "${path}" ]] || { touch "${path}"; }
  micro "${path}"
)
