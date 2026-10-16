#!/bin/bash


# == YOU CAN EITHER RUN DIRECTLY OR PASS THROUGH AUTOMATOR AS A QUICK ACTION

convert_audio() {
	# First argument: newline-separated POSIX paths
	files="$1"
	# Second argument: selected format
	format="$2"
	
	case "${format}" in
	  "WAV")
	    extension="wav"
	    input_flags=""
	    ;;
	  "AIFF")
	    extension="aiff"
	    input_flags="-c:a pcm_s16le"
	    ;;
	  "MP3")
	    extension="mp3"
	    input_flags="-c:a libmp3lame -q:a 2"
	    ;;
	  "MP4")
	    extension="mp4"
	    input_flags="-c:v libx264 -c:a aac"
	    ;;
	  "M4R")
	    extension="m4r"
	    input_flags="-vn -c:a aac -b:a 128k -f mp4 -t 29.99"
	    ;;
	  "GIF")
	    extension="gif"
	    input_flags='-vf "fps=10,scale=320:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse"'
	    ;;
	esac
	
	ffmpeg_path="/opt/homebrew/bin/ffmpeg"
	
	while IFS= read -r file; do
	  filename="${file%.*}"
	  "${ffmpeg_path}" -i "${file}" ${input_flags} "${filename}.${extension}"
	done <<< "${files}"
}
