#-------------#
# Screencasts #
#-------------#

# Transforms a screencast to a gif
# $1: the input video file name
# $2: if set to -r, removes temporary files (Optional)
# Uses: mplayer, imagemagick
scToGif() (
  printfc 'Generating images\n' "${CYAN}"
  mplayer -ao null "${1?Missing video screencast}" -vo jpeg:outdir=/tmp/output

  printfc 'Converting to Gif\n' "${CYAN}"
  convert /tmp/output/* /tmp/output.gif
  mv /tmp/output.gif ~/Desktop
  [[ "$2" = "-r" ]] && { rm -rf /tmp/output; }

  outputFile="${DESKTOP}/output.gif"
  printfc "Gif created at: ${outputFile}\n" "${GREEN}"
  cb <<< ~/Desktop/output.gif
  xo ~/Desktop/output.gif
)
