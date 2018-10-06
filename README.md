# math2img -- Converting math formula to image offline

![sample-output](sample/out.jpg)

## Introduction

This utility converts math formula (in LaTeX) to image of any format that `imagemagick` supports. The implementation is based on [TeX to image over command line](https://tex.stackexchange.com/questions/34054/tex-to-image-over-command-line/34058#34058). The above image is a sample output.

## Dependencies

- `texlive-full`
- `imagemagick`

Installation of dependencies (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install texlive-full imagemagick
```

## Installation

```bash
cd $DIRECTORY_TO_INSTALL
git clone https://github.com/kkew3/math2img.git
export PATH="$DIRECTORY_TO_INSTALL/math2img:$PATH"
```
## Support for Windows

Might work in Windows 10 WSL but never tested.


## Usage

	math2img.sh output-image [input-formula|-]
	
	output-image: the image file to write
	input-formula (optional): the file containing the formula to compile.
	                          The formula will be compiled as if it were
	                          stripped and placed between
	                          "\begin{equation*}" and "\end{equation*}".
	                          All commands in TeXLive packages "amsmath",
	                          "amssymb" and "physics" are supported.

If `input-formula` is not given, the default `EDITOR` will be opened so that
the user may enter the formula. If it's specified as `-`, the formula will be
read from `/dev/stdin` (and will loop if `/dev/stdin` is in fact empty). If
it's specified as a non-file string, the script terminates and returns 0, the
same behavior as specifying no formula, e.g. `echo | math2img.sh x.png -`.

## Examples

```bash
cat > formula << EOF
\begin{aligned}
f(x) &= \nabla g(x)\\
     &= \cdots\\
\end{aligned}
EOF
math2img.sh out.jpg formula
# check the produced image "out.jpg" now
```
or specify the formula without creating an intermediate file:

```bash
math2img.sh out.jpg
# Now a text editor is opened for you to fill in the math equation.
# Save and exit the editor to continue
# check the produced image "out.jpg" now
```

or specify the formula from stdin:

```bash
cat << EOF | math2img.sh out.jpg -
\begin{aligned}
f(x) &= \nabla g(x)\\
     &= \cdots\\
\end{aligned}
EOF
# check the produced image "out.jpg" now
```

If an invalid math formula is specified, no image will be produced.

## Error code

- `0`: success
- `1`: not specifying the image file to output
- `2`: error creating temporary working directory (occurs when, say, disk is full)
- `3`: error compiling the formula to PDF
- `4`: error converting PDF to image (occurs when, say, the image extension is not supported by `imagemagick`)


## Known issue

`ImageMagick` may prevent user from reading PDF file.
See detailed explanation of this issue and corresponding solution in [this post](https://stackoverflow.com/a/52661288).
