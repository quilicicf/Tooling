#---------#
# Network #
#---------#

alias wifiCode='nmcli dev wifi show-password'

# Displays information about the network configuration
netInfo() (
  printf '%s\n' '--------------- Network Information ---------------'

  localIp="$(ifconfig | awk '/inet 192\.168\.[0-9.]+  netmask [0-9.]+  broadcast [0-9.]+/ {print $2}')"
  printf 'Local IP: %s\n' "$localIp"

  publicIp="$(wget -qO- http://ipecho.net/plain)"
  printf 'Public IP: %s\n' "$publicIp"

  printf '%s\n' '---------------------------------------------------'
)

# Pings google to check internet connection
pingg() (
  printf 'Calling Mr Google....\n'
  ping 'google.fr' -c 5 | grep 'packets'
)

# Displays public IP
extIp() (
  curl 'http://ipecho.net/plain'
  printf '\n'
)
