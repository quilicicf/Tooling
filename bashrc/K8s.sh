#######
# K8s #
#######

alias k='kubectl'

# Displays or changes the current K8s context
kx() (
  if command -v kubectx &> /dev/null; then
    kubectx "$@"
    return "$?"
  fi

  context="$1"

  if [[  -n "${context}" ]]; then
     kubectl config use-context "${context}"
  else
     kubectl config get-contexts
  fi
)

kn() (
  namespace="$1"

  if [[ -n "${namespace}" ]]; then
    kubectl config set-context --current --namespace "${namespace}"
  else
    kubectl config view --minify \
      | grep 'namespace:' \
      | cut --delimiter ':' --fields '2' \
      | tr --delete ' '
  fi
)
