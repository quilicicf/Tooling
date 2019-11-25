#----------#
# Graphviz #
#----------#

# shellcheck disable=SC2034

# Watches the current directory for dot files and generates the associated image files
# each time the source file is modified.
# $1: image format, be careful with image size (default: svg)
dotify() {
  local path action file
  local outputFormat='svg'

  # Global
  local font='Ubuntu'
  local fontSize='24'
  local bgColor='#FFFFFF00'
  local fgColor='#7a7a7a'

  # Graph
  local titleSize='20'

  # Node
  local shape='box'
  local style='rounded'

  # Edge
  local arrowHead='empty'

  inotifywait -rm . -e close_write |
    while read path action file; do
      if [[ "$file" =~ .*\.dot$ ]]; then
        printf 'Generating file: %s\n' "$file"
        # -Gbgcolor="$bgColor" -Gfontcolor="$fgColor" -Gfontsize="$titleSize" \
        # -Nfontname="$font" -Nfontsize="$fontSize" -Nshape="$shape" -Nstyle="$style" -Ncolor="$fgColor" -Nfontcolor="$fgColor" \
        # -Efontname="$font" -Efontsize="$fontSize" -Earrowhead="$arrowHead" -Efontcolor="$fgColor" -Ecolor="$fgColor" \
        dot \
          -Gfontsize="$titleSize" \
          -Nfontname="$font" -Nfontsize="$fontSize" \
          -Efontname="$font" -Efontsize="$fontSize" \
          -T"$outputFormat" "$path$file" -o "$path${file//\.dot/\.$outputFormat}"
      fi
    done
}

pumlify() {
  inotifywait -rm . -e close_write |
    while read path action file; do
      if [[ "$file" =~ .*\.pu$ ]]; then
        printf 'Generating file: %s\n' "$file"
        cat "$path$file" \
          | plantuml -pipe -tsvg \
          | tr -d '\r' \
          > "$path${file/\.pu/.svg}"
      fi
    done
}
