#!/bin/bash
set -euo pipefail

i="/i"
o="/o"
progress_pipe=/tmp/progress_pipe
format=mkv
ffmpeg_opts=()
ffmpeg_opts+=(-progress "$progress_pipe" -stats_period 1)
ffmpeg_opts+=(-c:v libaom-av1) # slow, best quality
ffmpeg_opts+=(-crf 30) # quality (lower = higher quality, bigger file)
                       # 18 = quality prioritized
                       # 25 = balanced
                       # 35 = storage prioritized
ffmpeg_opts+=(-cpu-used 0 -row-mt 1)
ffmpeg_opts+=(-f matroska)

exit_with_message()
{
  # $1 = exit code
  # $2 = message
  echo "$2"
  exit "$1"
}

setup()
{
  mkdir -p "$i"
  mkdir -p "$o"
  mkfifo "$progress_pipe"
}

progress_parser()
{
  # TODO make it prometheus compatible
  local line
  while read -r line; do
    echo "$line"
  done < "$progress_pipe"
}

probe()
{
  # $1 = input file
  ffprobe "$1"

  # set vars for encode
  # /data/i/file.mp4 -> /data/o/file.mp4
  encoded_file="$o/${1##*/}"
  # /data/i/file.mp4 -> /data/o/file.${format}
  encoded_file="${encoded_file%.*}.${format}"
  # /data/o/file.${format}
  encoded_file_tmp="${encoded_file}.tmp"

  [ -e "$encoded_file" ] && return 1 # file already encoded
  echo "ready to encode to: $encoded_file"
  return 0
}

encode()
{
  # $1 = input file
  # $encoded_file = output file
  ffmpeg -i "$1" "${ffmpeg_opts[@]}" "$encoded_file_tmp"
  mv "$encoded_file_tmp" "$encoded_file"
}

process()
{
  local total=0

  # 1/2 count files
  for f in "$i"/* ; do
    [ -e "$f" ] || continue
    let ++total
  done
  [ $total -gt 0 ] || exit_with_message 0 "no files to process, exiting"

  # 2/2 encode
  for f in "$i"/* ; do
    [ -e "$f" ] || continue
    probe  "$f" || continue # sets vars for encode
    encode "$f" || continue
  done
}

main()
{
  setup
  progress_parser &
  process
}

main "$@"
