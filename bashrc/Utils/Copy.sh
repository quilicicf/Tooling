#------#
# Copy #
#------#

cb() {
  xclip -sel clipboard <<< "$(cat)"
}

cbo() {
  xclip -sel clipboard -o
}

# Copies what's piped to it to clipboard. Removes trailing line break.
cbs() {
  cat | xargs echo -n | xclip -sel clipboard
}
