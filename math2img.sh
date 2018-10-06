#!/bin/bash
show_help() {
	cat << EOF
Usage: $0 output-image [ input-math-file ]
If \`input-math-file\` is not specified, it will be prompted in \$EDITOR,
which if not set, default to "vi"). Input from stdin is not currently accepted.

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

# prepare arguments
srcdir=$(dirname ${BASH_SOURCE[0]})
if [ -z "$1" ]; then
	show_help
	exit 1
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	show_help
	exit 0
fi
outfile=$(realpath "$1")
if [ -z "$2" ]; then
	rm -f "$srcdir/math.tmp" "$srcdir"/*.swp
	touch "$srcdir/math.tmp"
	if [ -z "$EDITOR" ]; then
		EDITOR=vi
	fi
	$EDITOR "$srcdir/math.tmp"
	mathfile="$srcdir/math.tmp"
else
	mathfile="$2"
fi
if ! "$srcdir/hasformula.py" "$mathfile"; then
	echo "Math expression is empty; aborted"
	exit 0
fi
"$srcdir/stripformula.py" "$mathfile"

# conversion
CURDIR=$(pwd)
wdir=$(mktemp -d)
if [ "$CURDIR" = "$wdir" ]; then
	echo "Error creating temp directory; aborted"
	exit 2
fi
cat "$srcdir/prefix.txt" "$mathfile" "$srcdir/suffix.txt" > "$wdir/math.tex"
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
