#---------#
# Screens #
#---------#

_gnomeShowTopPanel() {
  gnome-shell-extension-tool -d hide-top-panel@dimka665.gmail.com
}

_gnomeHideTopPanel() {
  gnome-shell-extension-tool -e hide-top-panel@dimka665.gmail.com
}

gnomeHideTopPanel() {
  _gnomeShowTopPanel
  _gnomeHideTopPanel
}

_screenOffice() {
  xrandr \
    --output 'DP-3'   --pos '1920x0' --auto --rate '59.950172424316406' \
    --output 'HDMI-2' --pos '0x0'    --auto --rate '59.950172424316406' --primary
}

_screenTargus() {
  xrandr \
    --output 'DVI-I-2-1'  --pos '1920x0' --auto --rate '60' \
    --output 'DVI-I-3-2'  --pos '0x0'    --auto --rate '59.95' --primary
}

_screenLaptop() {
  xrandr --output 'eDP-1'   --pos '0x0' --auto --rate '60' --primary
}

screens() {
  local disposition="${1:--o}"

  if [[ "$disposition" = '-o' ]]; then
    _screenOffice
  elif [[ "$disposition" = '-t' ]]; then
    _screenTargus
  elif [[ "$disposition" = '-l' ]]; then
    _screenLaptop
  fi

  gnomeHideTopPanel
}
