#---------#
# Screens #
#---------#

gnomeHideTopPanel() {
  gnome-shell-extension-tool -d hide-top-panel@dimka665.gmail.com
  gnome-shell-extension-tool -e hide-top-panel@dimka665.gmail.com
}

_screenOffice() {
  xrandr \
    --output 'DP-2'   --pos '1920x0' --auto --rate '60' \
    --output 'DP-3-8' --pos '0x0'    --auto --rate '59.950172424316406' --primary
}

_screenLaptop() {
  xrandr --output 'eDP-1'   --pos '0x0' --auto --rate '60' --primary
}

screens() {
  local disposition="${1:--o}"

  if [[ "$disposition" = '-o' ]]; then
    _screenOffice
  elif [[ "$disposition" = '-l' ]]; then
    _screenLaptop
  fi

  gnomeHideTopPanel
}
