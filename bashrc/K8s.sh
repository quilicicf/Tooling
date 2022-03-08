#######
# K8s #
#######

alias k='kubectl'

# Displays or changes the current K8s context
kx() {
  local context="$1"

  if [[  -n "${context}" ]]; then
     kubectl config use-context "${context}"
  else
     kubectl config current-context
  fi
}

kn() (
  namespace="$1"

  if [[ -n "${namespace}" ]]; then
    kubectl config set-context --current --namespace "${namespace}"
  else
    kubectl config view --minify \
      | grep 'namespace:' \
      | cut --delimiter ':' --fields '2'
  fi
)
