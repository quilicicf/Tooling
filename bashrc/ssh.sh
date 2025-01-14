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
