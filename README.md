# math2img -- Converting math formula to image offline

![sample-output](sample/out.jpg)

## Introduction

This utility converts math formula (in LaTeX) to image of any format that `imagemagick` supports. The implementation is based on [TeX to image over command line](https://tex.stackexchange.com/questions/34054/tex-to-image-over-command-line/34058#34058). The above image is a sample output.

## Dependencies

- `texlive-full`
- `imagemagick`
- `ghostscript`
- `perl` (`v5.30` or above)

Installation of dependencies (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install texlive-full imagemagick ghostscript
```

## Installation

```bash
cd "$DIRECTORY_TO_INSTALL"
git clone https://github.com/kkew3/math2img.git
export PATH="$DIRECTORY_TO_INSTALL/math2img:$PATH"
```

## Support for Windows

Might work in Windows 10 WSL but never tested.

## Usage

> Copied from `math2img.pl -h`

```
Usage: ./math2img.pl [OPTIONS]... OUTFILE

This utility converts LaTeX formula to image by calling `xelatex' and
`convert' (ImageMagick).  The LaTeX formula may use any commands from
packages `amsmath' and `amssymb'.

Options:

    -f MATHFILE   a file where the math formula is presented; if MATHFILE is
                  specified as "-", then it will be read from /dev/stdin; if
                  the option is not specified, the text editor specified by
                  variable EDITOR will be opened for the user to type the math
                  equation; if EDITOR is not set, it's default to `vi'
    -h            display this help and exit

Argument:

    OUTFILE       to which to write the image

Return code:
    0             success
    1             command line option parsing error
    2             error raised when compiling PDF from LaTeX
    4             error raised when converting PDF to image file
    8             error raised when opening EDITOR

Examples:

    # save formula image to "image.png"
    echo 'f(x)' | math2img.pl -f- image.png

    # open $EDITOR and write the image to "my image.gif"
    math2img.pl "my image.gif"
```


## Known issue

`ImageMagick` may prevent user from reading PDF file.
See detailed explanation of this issue and corresponding solution in [this post](https://stackoverflow.com/a/52661288).


## See also

- [nwtgck/math2img](https://github.com/nwtgck/math2img.git)
