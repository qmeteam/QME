#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Term::ANSIColor;

my $cflags="";
my $fltfile="";
my $verbose=0;
my $vlogargs="";
my $vcomargs="";
my $default_lib="";
my $library_home="questa_libs";
my $arch="32";
sub infomsg{
    my $s = pop;
    print color 'bold dark blue';
    print "Note: $s\n";
    print color 'reset';
}



sub compile_file{
    my $lib=pop;
    my $file = pop;
    my $args="";
    my @f;
    my $cmd;
    my $type="";
    my $tmp;

    my @vmap=`vmap|grep "maps to"|grep -v $ENV{QUESTA_HOME}|cut -d" " -f1|sed s/\\"/-L\\ /|sed s/\\"//g`;
    chomp @vmap;
    my $mapped_libs=join " ",@vmap;

    if ($file =~ /:/) {
	my @line=split ":",$file;
	@f = split",",$line[0];
	$args = $line[1];
    } else {
	@f = split ",",$file;    
    }

    # ###############################################################
    # This is only valid if we have a library:
    # Check if this is a VHDL file
    # First of all. We will use the first file to decide file type
    # Then we will check if we have conflicting types
    # ###############################################################
    if (($f[0] =~ /\.vhd$/)|($f[0] =~ /\.vhdl$/)) {
	    $type="vhdl";
    } elsif (($f[0] =~ /\.sv$/)|($f[0] =~ /\.v$/)|($f[0] =~ /\.svh$/)) {
	$type="verilog";

    } elsif (($f[0] =~ /\.c$/)|($f[0] =~ /\.cpp$/)) {
	$type="c"; 
    } else {
	&infomsg("Unknown filetype:$f[0]");
	exit(1);
    }

    # Next step is to compile the code
    $tmp = join " ",@f;
    if ($type eq "vhdl") {
	$cmd = "vcom -$arch -work $lib $tmp $args $vcomargs";
	&system_cmd($cmd);
#	&infomsg("Trying to compile $type: $cmd");
    } elsif ($type eq "verilog") {
	$cmd = "vlog -$arch -work $lib $tmp $args $vlogargs $mapped_libs";
#	&infomsg("Trying to compile $type: $cmd");
	&system_cmd($cmd);
    } elsif ($type eq "c") {
	$cmd = "vlog -$arch -work $lib $tmp $args $cflags";
#	&infomsg("Trying to compile $type: $cmd");
	&system_cmd($cmd);
    } else {
	&infomsg("Unknown filetype:$type");
	exit(1);

    }



} 
 

GetOptions ("cflags=s" => \$cflags,    # numeric
	    "file=s"   => \$fltfile,      # string
	    "vlogargs=s" => \$vlogargs,
	    "vcomargs=s" => \$vcomargs,
	    "default_lib=s" => \$default_lib,
	    "arch=s"  => \$arch,
	    "verbose"  => \$verbose)   # flag
    or die("Error in command line arguments\n");




&infomsg("Parsing $fltfile");
open(FHIN, "<", $fltfile) 
    or die "cannot open $!";
# First remove all lines starting with "#"

my @indata=<FHIN>;
chomp @indata;
my @tmp;
foreach my $l (@indata) {
    if (($l =~/^\#/)|($l =~ /^$/)) {
#	print "DBG:skipping $l\n";
    } else {
	push @tmp,$l;
    }
}

@indata=@tmp;
my $lib=$default_lib;


foreach my $f (@indata) {
    if ($f =~ /^\@library/ ) {
	my @line=split "=",$f;
	$lib=pop @line;
	&infomsg("Trying to create library $lib");
	my $cmd="test -e $library_home||mkdir $library_home";
	&system_cmd($cmd);
	my $cmd="vlib $library_home/$lib";
	&system_cmd($cmd);
	my $cmd="vmap $lib $ENV{'PWD'}/$library_home/$lib";
	&system_cmd($cmd);
    } else {



	&compile_file($f,$lib);
    }
}



sub system_cmd{
    my $cmd = pop;
    my $status;
    $status=system($cmd);
    if ($status > 0) {
	die("$cmd failed, exiting...");
    }
}

#sub system_cmd_hl{
#    my $cmd = pop;
#    my $status;
#    my $tmp = "bash -o pipefail -c '$cmd|keyword_highlight.pl 0";'
#    $status=system($cmd);
#    if ($status > 0) {
#	die("$cmd failed, exiting...");
#    }
#}

