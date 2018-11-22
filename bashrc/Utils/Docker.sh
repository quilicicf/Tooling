#--------#
# Docker #
#--------#

_parseableDockerPs() {
  docker ps -a --format '{{.ID}}|{{.Image}}|{{.Names}}|{{.Status}}' | tail -n +1
}

dockerRm() {
  local image containerId name status

  if grep --quiet '\-a' <<< "$*"; then
    printfc 'Removing all exited containers\n' "$CYAN"
    while read -r image; do
      containerId="$(awk -F'|' '{print $1}' <<< "$image")"
      name="$(awk -F'|' '{print $3}' <<< "$image")"
      status="$(awk -F'|' '{print $4}' <<< "$image")"
      local fullContainerId="$name:$containerId"

      if [[ "$status" = Exited* ]]; then
        printfc "Container $fullContainerId removed\n" "$GREEN"
        docker rm "$containerId"

      else
        printfc "Image $fullContainerId still running\n" "$YELLOW"

      fi
    done <<< "$(_parseableDockerPs)"

  else
    printfc 'Removing exited containers in interactive mode\n' "$CYAN"
    local images=()
    while read -r image; do
      images+=("$image")
    done <<< "$(docker ps -a --filter status=exited | tail -n +1)"

    for image in "${images[@]}"; do
      containerId="$(awk '{print $1}' <<< "$image")"
      printf '%s\n' "$image"
      read -p "Delete container (y/N)? " -n 1 -r
      printf '\n'
      if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        printfc "Container removed\n" "$GREEN"
        docker rm "$containerId"
      else
        printfc "Container not deleted\n" "$YELLOW"
      fi
    done
  fi
}
