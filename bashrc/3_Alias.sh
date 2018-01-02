########################
#         APT          #
########################

alias apti="sudo apt-get install"
alias apts="sudo apt-cache search"
alias aptr="sudo apt-get remove"
alias aptud="sudo apt-get update"
alias aptug="sudo apt-get upgrade"
alias aptc="sudo apt-get clean"
alias aptac="sudo apt-get autoclean"
alias aptar="sudo apt-get autoremove"

#######################
#     Fools guard     #
#######################

alias rm="rm -viI --preserve-root"

alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias wget='wget -c'

#######################
#   Utility aliases   #
#######################

alias diff="colordiff"
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias jqcr='jq --compact-output --raw-output'
alias javar='java -jar'
alias g='gut'
alias npmi='npm i --save --save-exact'
alias npmid='npm i --save-dev --save-exact'
