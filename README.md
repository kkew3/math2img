# math2img -- Converting math formula to image offline

![sample-output](sample/out.svg)

*Image best viewed in light background.*

## Introduction

This utility converts math formula (in LaTeX) to SVG, which can be later converted to other image formats using e.g. `imagemagick`. The implementation is based on [TeX to image over command line](https://tex.stackexchange.com/questions/34054/tex-to-image-over-command-line/34058#34058). The above image is a sample output.

## Dependencies

- `texlive-full`
- `bash`

Installation of dependencies (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install texlive-full
```

## Installation

For example,

```bash
git clone --depth=1 https://github.com/kkew3/math2img.git && cd math2img
install math2img.sh ~/bin
```

## Support for Windows

Might work in Windows 10 WSL but never tested.

## Usage

### Examples

Below commands are runnable after cloning this repository:

```bash
# Write SVG output to sample/out.svg. This produces the image above.
./math2img.sh -f=sample/f.txt -o=sample/out.svg

# Pipe SVG to imagemagick and convert to PNG.
./math2img.sh -f=sample/f.txt | magick -density 500 -background white svg:- out.png

# Edit the formula in EDITOR.
./math2img.sh -o=out.svg

# Preview the latex source without conversion.
./math2img.sh -f=sample/f.txt -c

# This will error out if and EDITOR is required but stdout is non-interactive.
./math2img.sh -c | cat
```

Usage in Vim on Mac to preview the math formula in Safari.app:

1. Open a named buffer.
2. Edit your formula.
3. In cmdline, `:!math2img.sh -f=% -o=out.svg && open -a Safari out.svg`.

### Help message

> Copied from `math2img.sh -h`

```
Usage: math2img.sh [OPTION]...

Converts LaTeX formula to svg by calling `latex' followed by `dvisvgm'.
Without `-f' option, $EDITOR will be opened to allow the user input the
formula. The script respects $TMPDIR as the working directory. IF EDITOR is
not set, default to `vi'. If TMPDIR is not set, `/tmp' is used.

  -p=PACKAGE_LIST   usepackages, default to "amsmath,amssymb,mathtools,bbm"
  -P=PREAMBLE_FILE  specify the preamble file, overrides PACKAGE_LIST
  -f[=MATH_FILE]    specify the formula file, without MATH_FILE, read from stdin
  -e=ENV            specify the math environment, e.g. "aligned", default none
  -c                write the latex source to stdout and exit
  -o=OUTPUT_FILE    specify the output svg file, default to stdout
  -h                show this help message and exit
```


## See also

- [nwtgck/math2img](https://github.com/nwtgck/math2img.git)
