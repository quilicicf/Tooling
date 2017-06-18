#! /bin/bash

######################################
# Utility to switch keyboard layouts #
######################################

# To assign a shortcut to it, just go to Settings > Keyboard > Shortcuts
# Then in the Custom shortcuts section, add a shortcut with the command:
# gnome-terminal --working-directory=$TOOLING/scripts -e "./switch_keyboard.sh $TOOLING/scripts/keyboard_icon.png"

main() {
  local icon="$1"
  local kbd
  kbd="$(setxkbmap -query | grep layout | awk '{print $2}')"

  if [ 'fr' = "$kbd" ]; then
    notify-send -i "$icon" 'Keyboard: Dvorak'
    setxkbmap dvorak en -option compose:ralt
  else
    notify-send -i "$icon" 'Keyboard: French'
    setxkbmap fr -option
  fi
}

main "$1"
