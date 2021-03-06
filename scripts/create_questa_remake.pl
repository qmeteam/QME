#!/usr/bin/perl -w
# *************************************************************************************
# create_questa_remake.pl
# Questa Makefile Environment
#
# Copyright 2014 Mentor Graphics Corporation
# All Rights Reserved
#
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
# MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
#
# bugs, enhancment requests to: Mikael_Andersson@mentor.com
# ************************************************************************************

##################################################################
# Usage create_questa_remake.pl
# Script that generates a makefile for all source files for
# questasim libraries specified in the liborder.txt file
# The makefile can then be used for recompilation of only the
# smallest possible number of source files.
# Works for VHDL, Verilog and SystemVerilog files.
# As of yet not supporting Clearmake so going back in time
# doesn't work.
# The script uses QuestaSims "vdir -prop top" and "vdir -fulloptions"
# to get the necessary information from the compiled libraries
#
# Todo: Get the compile order from the "vdir -prop cmpltime -lib <library>"
#
##################################################################
#my $liborder_file="./questa_libs/liborder.txt";
my $remake_file=pop;
my $liborder_file=pop;
my $libpath=pop; 
my $libref;

# Step one is to identify in which order the libraries are compiled and keep that.
open FILE, $liborder_file or die $!;
my @libs = <FILE>;
chomp @libs;
close FILE;

open MFILE, ">$remake_file" or die $!;


@libs_copy = @libs;
@libs=();
$prev_lib="";
foreach  $l (@libs_copy) {
    if ($prev_lib=~/$l/) {
        #       print MFILE "# Note: $l already compiled - skipping\n";
    } elsif (exists $libref{$l}) {
        print MFILE "# Warning: $l already compiled once removing previous occurence of this lib.\n";
        $index=0;
        $index++ until $libs[$index] eq $l;
        splice(@libs, $index, 1);
        push @libs,$l;
        $prev_lib=$l;
    } else {
        $libref{$l} = 1;
        #       print MFILE "-> $l = $libref{$l}\n";
        # Lets keep the last name only
        #       @tmp=split "/",$l;
        push @libs,$l;
        $prev_lib=$l;
    }
}

print MFILE "########### This files is autogenerated #####################\n";
foreach  $l (@libs) {
    print MFILE "# indentified library $l from logfiles\n";
}
print MFILE "#############################################################\n";

$previous_lib="";

@tmp=@libs;
$all=pop @tmp;

print MFILE "all:./$libpath/touchfiles/$all\n\n";

# first we need to identify all verilog files in the library
foreach  $l (@libs) {
    print MFILE "./$libpath/touchfiles/$l: \\\n\t";
    print MFILE "$previous_lib \\\n\t";
    @source=`$ENV{"QUESTA_HOME"}/bin/vdir -prop source -lib $l|grep Source|grep -v $ENV{"QUESTA_HOME"}|grep -v $l/_temp `;
    chomp @source;
    # Sometimes we get multiple instances of the same file.
    $before="";
	 @source_tmp =();
    foreach (@source) {
        if ($before eq $_) {
            # print MFILE "# Skipping $_\n";
        } else {
            push @source_tmp,$_;
            $before=$_;
            # print MFILE "# Keeping $_\n";
        }
    }
    @source=@source_tmp;
    foreach $s(@source) {
        @tmp=split ":",$s;
        print MFILE "$tmp[1] \\\n\t";
    }
    print MFILE "\n";
    $previous_lib="./$libpath/touchfiles/$l";
#	 print MFILE "##DBG:##previous=$previous_lib##\n";
    # Lets extract all VHDL packages first of all.
    # Then all entities
    @du_vhdl=`$ENV{"QUESTA_HOME"}/bin/vdir -prop top -lib $l | grep -v Verilog | grep -v MODULE|grep -v INTERFACE|grep -v UDP|grep -v SYSTEMC | grep -v SYSTEMC|grep -v linux_gcc|grep -v ^OPTIMIZED|grep -v "Top-level model:"|grep -v ^DPI `;
#	 print MFILE "DBG:du_vhdl=##@du__vhdl##\n";
    chomp @du_vhdl;
    @vhdldu=();
    foreach $vhdf (@du_vhdl){
        @tmp = split " ",$vhdf;
        if ($vhdf =~ /PACKAGE/) {
            push @vhdldu,$tmp[2];
        } else {
            push @vhdldu,$tmp[1];
        }
    }
#	 print MFILE "DBG:vhdldu=##@vhdldu##\n";
    # Get the source file for each du
    @vhdlcommand=("vcom");
    $found_vhdl=0;
    foreach $du (@vhdldu) {
        @tmp = `$ENV{"QUESTA_HOME"}/bin/vdir -prop source -lib $l $du|grep Source|head -1`;
        chomp @tmp;
        @x = split ":",$tmp[0];
        # print MFILE "\t$x[1] \\\n";
        push @vhdlcommand,"$x[1] \\\n\t";
        $found_vhdl=1;
        @tmp=`$ENV{"QUESTA_HOME"}/bin/vdir -prop options -lib $l $du | grep Compile | cut -d":" -f2|head -1 `;
    }
    $line = join " ",@vhdlcommand;
    # Check if library actually exists
    #    print MFILE "\ttest -d ./$libpath/$l||vlib ./$libpath/$l\n";
    if ($found_vhdl) {
        print MFILE "\t$line $tmp[0]\n";
    }

    #    print MFILE "########################################\n";
    # Time for Verilog packages
    @du_vlog=`$ENV{"QUESTA_HOME"}/bin/vdir -prop top -lib $l | grep -v VHDL | grep -v ENTITY| grep -v SYSTEMC|grep -v linux_gcc|grep -v ^OPTIMIZED|grep -v "Top-level model:"|grep -v ^DPI|grep -v zzbind_to_vhdl_implicitzz`;
#	 print MFILE "DBG:##du_vlog=##@du_vlog##\n";
    chomp @du_vlog;
    @vlogdu=();
    foreach $vlogf (@du_vlog){
        @tmp = split " ",$vlogf;
        if ($vlogf =~ /PACKAGE/) {
            push @vlogdu,$tmp[2];
        } else {
            push @vlogdu,$tmp[1];
            # print MFILE "DBG $tmp[1]\n";
        }
    }
#	 print MFILE "DBG:##vlogdu=@vlogdu##\n";

    #  keeping file specific compile options for vlog instead of joinig one line

    @vlogcommands=();
    foreach $du (@vlogdu) {
#	print MFILE "#DBG working on $du\n";
        @tmp = `$ENV{"QUESTA_HOME"}/bin/vdir -prop source -lib $l $du|grep Source|head -1`;
        chomp @tmp;
        @x = split ":",$tmp[0];
        # print MFILE "\t$x[1] \\\n";
#		  print MFILE "#DBG: l=##$l##,du=##$du##\n";
		  
        @tmp=`$ENV{"QUESTA_HOME"}/bin/vdir -prop fulloptions -lib $l $du | grep compile | cut -d":" -f2|head -1`;
#       print MFILE "DBG:tmp=##@tmp##\n";
		  # Check if empty otherwise get options
        if (@tmp==0) {
        
            @tmp=`$ENV{"QUESTA_HOME"}/bin/vdir -prop options -lib $l $du | grep Compile | cut -d":" -f2|head -1`;
            # print MFILE "#DBG $tmp[0]\n";
        }
#        print MFILE "DBG:vlogcommands=##@vlogcommands##\n,##$x[1]##\\\n\t##$tmp[0]##\n";
		  ### Need to safeguard against vhdl packages that were' compiled with -mixedsvvh switch
		  ### Check if .vhd and vlog command if so assume it shouldn't be compiled
		  if ($x[1] !~/\.vhd.*$/) {
           push @vlogcommands,"vlog $x[1] \\\n\t$tmp[0]";
		  }
    }
    foreach (@vlogcommands) {
        print MFILE "\t$_\n";
    }
    print MFILE "\ttouch ./$libpath/touchfiles/$l\n\n";
    print MFILE "######################################################\n";
}

