#######
# K8s #
#######

alias k8='kubectl'

# Displays or changes the current K8s context
k8x() {
  local context="$1"

  if [[  -n "${context}" ]]; then
     kubectl config use-context "${context}"
  else
     kubectl config current-context
  fi
}
