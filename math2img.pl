#!/usr/bin/env perl
use v5.30;
use warnings;
use strict;

use Cwd         qw/cwd/;
use Env         qw/EDITOR/;
use File::Temp  qw/tempdir/;
use Getopt::Std qw/getopts/;

# add/remove packages as you'd like!
my @use_packages = qw/amsmath amssymb/;

sub usage {
    print(<<EOF);
Usage: $0 [OPTIONS]... OUTFILE

This utility converts LaTeX formula to image by calling \`xelatex' and
\`convert' (ImageMagick).  The LaTeX formula may use any commands from
packages \`amsmath' and \`amssymb'.

Options:

    -f MATHFILE   a file where the math formula is presented; if MATHFILE is
                  specified as "-", then it will be read from /dev/stdin; if
                  the option is not specified, the text editor specified by
                  variable EDITOR will be opened for the user to type the math
                  equation; if EDITOR is not set, it's default to \`vi'
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

    # open \$EDITOR and write the image to "my image.gif"
    math2img.pl "my image.gif"
EOF
}

my $ERRNO_CMDOPT     = 1;
my $ERRNO_XELATEX    = 2;
my $ERRNO_CONVERT    = 4;
my $ERRNO_EDITORFAIL = 8;

my $CURDIR = cwd();
my $TMPDIR = tempdir( CLEANUP => 1 );

my $mathfile;
my $outfile;
my $EDITOR;

sub init {
    my %opt;
    if ( !getopts( "f:h", \%opt ) ) {
        print STDERR ("Failed to parse command line arguments\n");
        exit($ERRNO_CMDOPT);
    }
    if ( $opt{h} ) {
        usage();
        exit();
    }

    $mathfile = $opt{f} if defined $opt{f};
    $outfile  = shift(@ARGV);
    if ( !defined $outfile ) {
        print STDERR ("OUTFILE not specified\n");
        exit($ERRNO_CMDOPT);
    }
    $EDITOR = "vi" unless defined $EDITOR;
}

sub prepare_math {
    my @eq;
    if ( !defined $mathfile && -t STDOUT ) {
        chdir($TMPDIR);
        my $outname = "localmathfile";
        open( my $outfile, ">", $outname ) or die;
        close($outfile)                    or die;
        system( $EDITOR, $outname );
        open( my $infile, "<", $outname ) or die;
        @eq = <$infile>;
        close($infile) or die;
    }
    elsif ( !defined $mathfile ) {
        print("Failed to open $EDITOR\n");
        exit($ERRNO_EDITORFAIL);
    }
    elsif ( $mathfile eq "-" ) {
        @eq = <STDIN>;
    }
    else {
        chdir($CURDIR);
        open( my $infile, "<", $mathfile ) or die;
        @eq = <$infile>;
        close($infile) or die;
    }

    @eq = map { /^\s*$/ ? () : $_ } @eq;
    return @eq;
}

sub prepare_tex {
    my @eq   = prepare_math();
    my @sbuf = ();
    push( @sbuf, "\\documentclass[a5paper]{article}\n" );
    for my $pack (@use_packages) {
        push( @sbuf, "\\usepackage{$pack}\n" );
    }
    push( @sbuf, "\\pagenumbering{gobble}\n" );
    push( @sbuf, "\\DeclareMathSizes{12}{30}{16}{12}\n" );
    push( @sbuf, "\\begin{document}\n" );
    push( @sbuf, "\\begin{equation*}\n" );
    push( @sbuf, @eq );
    push( @sbuf, "\\end{equation*}\n" );
    push( @sbuf, "\\end{document}\n" );
    return join("", @sbuf);
}

sub conversion {
    my $tex = prepare_tex();

    # latex -> pdf
    chdir($TMPDIR);
    my $tex_name = "math.tex";
    open( my $outtex, ">", $TMPDIR . "/" . $tex_name ) or die;
    print $outtex ($tex);
    close($outtex) or die;
    if ( system( "xelatex", "-interaction=nonstopmode", $tex_name ) != 0 ) {
        exit($ERRNO_XELATEX);
    }

    # pdf -> image
    chdir($CURDIR);
    my @cmds = qw/convert -density 300/;
    push( @cmds, $TMPDIR . "/math.pdf" );
    push( @cmds, qw/-quality 90 -trim/ );
    push( @cmds, $outfile );

    if ( system(@cmds) != 0 ) {
        exit($ERRNO_CONVERT);
    }
}

print STDERR "Temporary working directory: $TMPDIR\n";
init();
conversion();
