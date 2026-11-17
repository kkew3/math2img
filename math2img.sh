#!/usr/bin/env bash

print_help() {
    cat <<EOF
Usage: math2img.sh [OPTION]...

Converts LaTeX formula to svg by calling \`latex' followed by \`dvisvgm'.
Without \`-f' option, \$EDITOR will be opened to allow the user input the
formula. The script respects \$TMPDIR as the working directory. IF EDITOR is
not set, default to \`vi'. If TMPDIR is not set, \`/tmp' is used.

  -p=PACKAGE_LIST   usepackages, default to "amsmath,amssymb,mathtools,bbm"
  -P=PREAMBLE_FILE  specify the preamble file, overrides PACKAGE_LIST
  -f[=MATH_FILE]    specify the formula file, without MATH_FILE, read from stdin
  -e=ENV            specify the math environment, e.g. "aligned", default none
  -c                write the latex source to stdout and exit
  -o=OUTPUT_FILE    specify the output svg file, default to stdout
  -Z=ZOOM_FACTOR    specify the zooming of the produced svg
  -h                show this help message and exit
EOF
}

printf_latex_cmd() {
    local format="$1"
    shift
    printf "%s$format" '\' "$@"
}

has() {
    command -v "$1" > /dev/null 2>&1
}

package_list="amsmath,amssymb,mathtools,bbm"
preamble_file=
output_file=
math_file=
math_file_provided=
math_env=
write_latex=
write_help=
svg_zoom=
_editor="${EDITOR:-vi}"
_tmpdir="${TMPDIR:-/tmp}"
while [[ -n "$1" ]]; do
    case "$1" in
        -p=*)
            package_list="${1:3}"
            ;;
        -P=*)
            preamble_file="${1:3}"
            ;;
        -f)
            math_file_provided=1
            ;;
        -f=*)
            math_file_provided=1
            math_file="${1:3}"
            ;;
        -e=*)
            math_env="${1:3}"
            ;;
        -c)
            write_latex=1
            ;;
        -h)
            write_help=0
            ;;
        -o=*)
            output_file="${1:3}"
            ;;
        -Z=*)
            svg_zoom="${1:3}"
            ;;
        *)
            write_help=1
            ;;
    esac
    shift
done

if [[ -n "$write_help" ]]; then
    if [[ "$write_help" = "1" ]]; then
        print_help >&2
        exit "$write_help"
    fi
    print_help
    exit 0
fi

if [[ ! -t 1 ]] && [[ -z "$math_file_provided" ]]; then
    echo "Error: stdout is not interactive but MATH_FILE is not provided" >&2
    echo >&2
    print_help >&2
    exit 1
fi

for cmd in latex dvisvgm; do
    if ! has $cmd; then
        echo "Error: missing: $cmd" >&2
        exit 1
    fi
done

cwd="$(pwd)"
workdir="$(mktemp -d "$_tmpdir/tmp.XXXXXX")"
if [[ -z "$workdir" ]]; then
    echo "Error: failed to create working directory" >&2
    exit 1
fi


# Write preamble.
if [[ -n "$preamble_file" ]]; then
    cp "$preamble_file" "$workdir/math.tex"
else
    printf_latex_cmd "documentclass[a5paper]{article}\n" > "$workdir/math.tex"
    printf_latex_cmd "usepackage{%s}\n" "$package_list" >> "$workdir/math.tex"
    printf_latex_cmd "pagenumbering{gobble}\n" >> "$workdir/math.tex"
    printf_latex_cmd "DeclareMathSizes{12}{30}{16}{12}\n" >> "$workdir/math.tex"
fi

# Write body.
printf_latex_cmd "begin{document}\n" >> "$workdir/math.tex"
printf_latex_cmd "begin{equation*}\n" >> "$workdir/math.tex"
if [[ -n "$math_env" ]]; then
    printf_latex_cmd "begin{%s}\n" "$math_env" >> "$workdir/math.tex"
fi
if [[ -n "$math_file_provided" ]]; then
    if [[ -n "$math_file" ]]; then
        cp "$math_file" "$workdir/formula.tex"
    else
        cat > "$workdir/formula.tex"
    fi
else
    echo "% Delete everything, save and exit to abort" > "$workdir/formula.tex"
    "$_editor" "$workdir/formula.tex"
fi
if [[ ! -s "$workdir/formula.tex" ]]; then
    echo "aborted" >&2
    rm -rf "$workdir"
    exit 2
fi
cat "$workdir/formula.tex" >> "$workdir/math.tex"
if [[ -n "$math_env" ]]; then
    printf_latex_cmd "end{%s}\n" "$math_env" >> "$workdir/math.tex"
fi
printf_latex_cmd "end{equation*}\n" >> "$workdir/math.tex"
printf_latex_cmd "end{document}\n" >> "$workdir/math.tex"

if [[ -n "$write_latex" ]]; then
    cat "$workdir/math.tex"
    rm -rf "$workdir"
    exit 0
fi

cd "$workdir"
latex math.tex > /dev/null
if [[ -n "$svg_zoom" ]]; then
    dvisvgm --zoom="$svg_zoom" --no-fonts math.dvi > /dev/null
else
    dvisvgm --no-fonts math.dvi > /dev/null
fi
cd "$cwd"

if [[ ! -s "$workdir/math.svg" ]]; then
    echo "Error: failed to generate svg" >&2
    rm -rf "$workdir"
    exit 1
fi

if [[ -n "$output_file" ]]; then
    cp "$workdir/math.svg" "$output_file"
else
    cat "$workdir/math.svg"
fi
rm -rf "$workdir"

# vim:et:ts=4:sw=4:sts=4:
