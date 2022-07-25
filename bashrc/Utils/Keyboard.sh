#----------#
# Keyboard #
#----------#

# Disables annoying keys on the keyboard (num lock, caps lock & insert)
kbconfig() (
  xmodmap -e 'keycode 77 = NoSymbol NoSymbol Num_Lock'
  xmodmap -e 'keycode 66 = NoSymbol NoSymbol Caps_Lock'
  xmodmap -e 'keycode 118 = NoSymbol NoSymbol NoSymbol'
  printf 'Caps lock, Insert and num lock deactivated\n'
)

# Re-binds annoying keys on the keyboard (num lock, caps lock & insert)
kbrebind() (
  xmodmap -e 'keycode 77 = Num_Lock NoSymbol Num_Lock'
  xmodmap -e 'keycode 66 = Caps_Lock NoSymbol Caps_Lock'
  xmodmap -e 'keycode 118 = Insert NoSymbol NoSymbol'
  printf 'Caps lock, Insert and num lock re-bound\n'
)

# IntelliJ-shitty-f***g-behavior-fixer
# (when kbconfig has been called BEFORE launching Intellij, for some reason the numpad doesn't work)
kbrc() (
  kbrebind
  kbconfig
)
