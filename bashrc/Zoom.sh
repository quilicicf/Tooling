###########
#   Zoom  #
###########

zoomUpdate() {
  local tempFile='/tmp/zoom_latest.deb'
  curl --location https://zoom.us/client/latest/zoom_amd64.deb --output "$tempFile"
  sudo apt install "$tempFile"
  rm "$tempFile"
}
