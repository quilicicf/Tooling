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
