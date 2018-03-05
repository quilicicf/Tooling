#---------#
# Network #
#---------#

# Displays information about the network configuration
netinfo() {
  local localIp publicIp
  printf '%s\n' '--------------- Network Information ---------------'

  localIp="$(ifconfig | awk '/inet 192\.168\.[0-9.]+  netmask [0-9.]+  broadcast [0-9.]+/ {print $2}')"
  printf 'Local IP: %s\n' "$localIp"

  publicIp="$(wget -qO- http://ipecho.net/plain)"
  printf 'Public IP: %s\n' "$publicIp"

  printf '%s\n' '---------------------------------------------------'
}

# Re-routes a port locally
# $1: source port
# $2: target port
netreroute() {
  sudo iptables -t nat -A PREROUTING -p tcp --dport "$1" -j REDIRECT --to-ports "$2"
}

# Pings google to check internet connection
alias pingg="echo \"Calling Mr Google....\"; ping \"google.fr\" -c 5 | grep packets"

# Displays public IP
alias extip="wget -qO- http://ipecho.net/plain ; echo"
