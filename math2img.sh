#!/bin/bash
show_help() {
	cat << EOF
Usage: $0 output-image [ input-math-file | - ]
If \`input-math-file\` is not specified, it will be prompted in \$EDITOR,
which if not set, default to "vi"). If \`input-math-file\` is specified as '-',
The formula will be read from stdin.

Usage example:
	echo 'f(x)=2x+1' > math.txt
	$(basename $0) out.jpg math.txt

Return code:
- 0: success, or aborted when no math equation is specified (e.g. after 
     exitting the editor before inputing anything)
- 1: \`output-image\` is not specified
- 2: error creating temporary directory
- 3: when failing to compile PDF from the underlying LaTeX file
- 4: when failing to convert PDF file to image file
EOF
}


readonly srcdir=$(dirname ${BASH_SOURCE[0]})
readonly localmathfile="$srcdir/math.tmp"


parse_args() {
	if [ -z "$1" ]; then
		show_help
		exit 1
	elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		show_help
		exit 0
	fi
	outfile="$(realpath "$1")"
	mathfile="$2"
}


# Prepare math formula into $localmathfile
prepare_math() {
	rm -f "$srcdir"/*.swp
	if [ -z "$mathfile" ]; then
		if [ -z "$EDITOR" ]; then
			EDITOR=vi
		fi
		> "$localmathfile"
		$EDITOR "$localmathfile"
	elif [ "$mathfile" = "-" ]; then
		cat /dev/stdin > "$localmathfile"
	elif [ -f "$mathfile" ]; then
		cp "$mathfile" "$localmathfile"
	else
		# this leads to "Math expression is empty"
		> "$localmathfile"
	fi
	if ! "$srcdir/hasformula.py" "$localmathfile"; then
		echo "Math expression is empty; aborted"
		exit 0
	fi
	"$srcdir/stripformula.py" "$localmathfile"
}


# Do the conversion $localmathfile -> LaTeX -> PDF -> Image
conversion() {
	local CURDIR=$(pwd)
	local wdir=$(mktemp -d)
	if [ "$CURDIR" = "$wdir" ]; then
		echo "Error creating temp directory; aborted"
		exit 2
	fi
	cat "$srcdir/prefix.txt" "$localmathfile" "$srcdir/suffix.txt" > "$wdir/math.tex"
	cd "$wdir"
	if ! pdflatex math.tex; then
		cd "$CURDIR"
		rm -rf "$wdir"
		exit 3
	fi
	if ! convert -density 300 math.pdf -quality 90 -trim "$outfile"; then
		cd "$CURDIR"
		rm -rf "$wdir"
		exit 4
	fi
	cd "$CURDIR"
	rm -rf "$wdir"
	echo "Removed temp working directory $wdir"
}


main() {
	parse_args "$@"
	prepare_math
	conversion
}


main "$@"
