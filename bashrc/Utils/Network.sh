#---------#
# Network #
#---------#

# Displays information about the network configuration
netinfo() {
  printf '--------------- Network Information ---------------\n'
  /sbin/ifconfig | awk /'inet addr/ {print $2}'
  /sbin/ifconfig | awk /'Bcast/ {print $3}'
  /sbin/ifconfig | awk /'inet addr/ {print $4}'
  /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
  myIP=$(wget -qO- http://ipecho.net/plain)
  printf 'Public: %s\n' "$myIP"
  printf '---------------------------------------------------'
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
