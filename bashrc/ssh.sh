###############
#     SSH     #
###############

sshCreateKey() (
  email="${1:?Missing email}"
  fileName="${2:?Missing file name}"

  filePath="${HOME}/.ssh/${fileName}"
  ssh-keygen -t 'ed25519' \
    -C "${email}" \
    -f "${filePath}"
  eval "$(ssh-agent -s)"
  ssh-add "${filePath}"
)

sshGrep() (
  search="${1:?Missing search text}"
  mapfile -t lines < <(grep -E "^Host .*${search}" ~/.ssh/config)
  if [[ "${#lines[@]}" == 0 ]]; then
    printf 'No match found\n'
    return 1
    
  elif [[ "${#lines[@]}" == 1 ]]; then
    [[ "${lines[0]}" =~ ^Host\ *([^\ ]*) ]]
    firstAlias="${BASH_REMATCH[1]}"
    printf 'Match : %s\n' "${lines[0]}"
    printf 'SSHing : %s\n' "${firstAlias}"
    ssh "${firstAlias}"
    return 0

  else
    printf 'Too many matches :\n'
    printf ' * %s\n' "${lines[@]}"
    return 1
  fi
)

sshTunnelBdd() (
  localPort="${1:?Missing local port}"
  remotePort="${2:?Missing remote port}"
  remoteAlias="${3:?Missing remote alias}"
  shift; shift; shift;
  additionalArgs="$@"

  # -f Push SSH to background
  # -N Do not execute a remote command
  # -g Allows remote hosts to connect to forwarded ports
  # -L Port forwarding
  ssh -fNg -L "${localPort}:127.0.0.1:${remotePort}" "${remoteAlias}" "$@"
)

_sshComplete() 
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="$(
    grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null \
      | grep -v '[?*]' \
      | cut -d ' ' -f 2- \
      | while read -r line; do 
        splitLine=($line);
        printf '%s\n' "${splitLine[@]}";
      done
  )"

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}
complete -F _sshComplete ssh
