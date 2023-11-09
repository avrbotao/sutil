#!/usr/bin/env perl

use strict;
use warnings;

### 
###           |          _                   |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
###           |\       _/ \_                 |       alexandre  botao       |
###           | \_    /_    \_               |         botao dot org        |
###           \   \__/  \__   \              |       +55-11-98244-UNIX      |
###            \_    \__/  \_  \             |       +55-11-9933-LINUX      |
###              \_   _/     \ |             |  alexandre at botao dot org  |
###                \_/        \|             |      botao at unix  dot net  |
###                            |             |______________________________|
### 


my $SWNAME="sshdconfctl.pl";
my $SWVERS="1.0.9";
my $SWDATE="2023-11-08";
my $SWTIME="00:00:00";
my $SWDESC="sshd config control";
my $SWTAGS="sshd,config,control";
my $SWCOPY="BSD2Clause";
my $SWAUTH="alexandre botao";
my $SWMAIL="alexandre at botao dot org";


##  __________________________________________________________________________
## |                                                                          |
## |  The source code in this file is part of the "sutil" software project    |
## |  as developed and released by alexandre botao <from botao dot org> ,     |
## |  available for download from the following public repositories:          |
## |  https://sourceforge.net/u/avrbotao/                                     |
## |  https://bitbucket.org/alexandrebotao/                                   |
## |  https://gitlab.com/alexandre.botao/                                     |
## |  https://github.com/avrbotao/                                            |
## |__________________________________________________________________________|
## |                                                                          |
## |  This software is free and open-source: you can use it under the terms   |
## |  of the "2-Clause BSD License" or as stated in the file "sutil-LICENSE"  |
## |  provided with this distribution.                                        |
## |  This software is distributed in hopes of being useful, but WITHOUT ANY  |
## |  EXPRESS OR IMPLIED WARRANTIES as detailed in the aforementioned files.  |
## |__________________________________________________________________________|
##


#______________________________________________________________________________
#

my @conflines;
my @morelines;

#______________________________________________________________________________
#

sub dumpwhis {
	foreach (@conflines) {
		next if /^$/;
		if ( /^\s+#/ ) {
			print ">>> improper comment <<<$_>>>\n";
		} else {
			print "$_\n" if /^\s+/;
		}
	}
}

sub dumparms {
	foreach (@conflines) {
		next if /^$/;
		print "$_\n" if ! /^#/;
	}
}

sub dumpcomm {
	foreach (@conflines) {
		next if /^$/;
		if ( /^\s+#/ ) {
			print ">>> improper comment <<<$_>>>\n";
		} else {
			print "$_\n" if /^#/;
		}
	}
}

sub dumpfull {
	my $report;
# print join("\n", @conflines);
	$report = join "\n", @conflines;
	print "===\n";
	print "$report\n";
	print "===\n";
}

sub usage {
	print "use: $0 [options]\n";
	print "--allowuser=\"list\"    add global AllowUsers list\n";
	print "--conf=<path>           input sshd config from <pathname>\n";
	print "--comm                  print sshd config comment lines\n";
	print "--dump                  print all sshd config lines\n";
	print "--diff                  run diff after changes\n";
	print "--help                  print usage syntax and exit\n";
	print "--parms                 print sshd config params\n";
	print "--reason=\"text\"       action description text\n";
	print "--save=<path>           output changed sshd config to <filename>\n";
	print "--space                 print sshd config conditional actions\n";
	print "--srch=\"list\"         search sshd config param(s)\n";
	print "--sshd=<path>           use sshd binary on <pathname>\n";
	print "--test                  check new sshd config sanity\n";
	exit(0);
}

#______________________________________________________________________________
#

use Getopt::Long;

GetOptions(
  'allowuser=s'		=> \my $ausrlist,
  'conf=s'			=> \my $confname,
  'comm'			=> \my $commflag,
  'dump'			=> \my $dumpflag,
  'diff'			=> \my $diffflag,
  'help'			=> \my $helpflag,
  'parms'			=> \my $parmsflag,
  'reason=s'		=> \my $reasonstr,
  'save=s'			=> \my $savename,
  'space'			=> \my $spaceflag,
  'srch=s'			=> \my $srchlist,
  'sshd=s'			=> \my $sshdname,
  'test'			=> \my $testflag,
  'verb'			=> \my $verbflag,
) or die ">>> $0: invalid options\n";

#______________________________________________________________________________
#

sub srchthis {
	foreach my $lin (@conflines) {
		next if $lin =~ /^$/ or $lin =~ /^#/ or $lin =~ /^\s+#/;
		my @srchvect = split /[,\s]+/ , $srchlist;
		foreach my $pat (@srchvect) {
			if ( $lin =~ /$pat/i ) {
				print "$lin\n"; last;
			}
		}
	}
}

#______________________________________________________________________________
#

my $ymdhms;

sub gettod {
	my ($sec,$min,$hour,$mday,$mon,$year) = localtime;
	$year += 1900;
	$mon += 1;
	if (length($sec)  == 1) {$sec  = "0$sec";}
	if (length($min)  == 1) {$min  = "0$min";}
	if (length($mon)  == 1) {$mon  = "0$mon";}
	if (length($hour) == 1) {$hour = "0$hour";}
	if (length($mday) == 1) {$mday = "0$mday";}
	$ymdhms = "$year/$mon/$mday $hour:$min:$sec";
}

#______________________________________________________________________________
#

sub addallowuser {
	if ( $reasonstr ) {
		gettod;
		push(@morelines, "\n# begin sshdconfctl global AllowUsers (:$reasonstr:) $ymdhms");
		push(@morelines, "AllowUsers $ausrlist");
		push(@morelines, "# e_n_d sshdconfctl global AllowUsers (:$reasonstr:) $ymdhms\n");
	} else {
		print STDERR ">>> $0: action requires --reason option\n"; usage;
	}
}

#______________________________________________________________________________
#

usage if $helpflag;

if ( ! $confname ) {
	print STDERR ">>> $0: missing config filename\n"; usage;
}

my $CFH;

unless (open $CFH, "<", $confname) {
	print STDERR ">>> $0: can't open '< $confname': $!\n"; exit(1);
}

chomp(@conflines = <$CFH>);

unless (close $CFH) {
	print STDERR ">>> $0: error closing '$confname': $!\n"; exit(1);
}

dumpfull if $dumpflag;
dumpcomm if $commflag;
dumparms if $parmsflag;
dumpwhis if $spaceflag;

srchthis if $srchlist;

addallowuser if $ausrlist;

if ( $savename ) {
	my $SFH;

	unless (open $SFH, ">", $savename) {
		print STDERR ">>> $0: can't open '> $savename': $!\n"; exit(1);
	}

	if ( @morelines ) {
		my( @index )= grep { $conflines[$_] =~ /^Match/i } 0..$#conflines;
		if ( $#index ) {
			if ( @index ) {
				print "Index : @index\n" if ($verbflag);
			}
			if ( $index[0] ) {
				my $mark = $index[0];
				print "mark = $mark\n" if ($verbflag);
				splice @conflines, $mark, 0, @morelines;
			}
		} else {
			push(@conflines, @morelines);
		}
	}

	print $SFH "$_\n" for @conflines;

	unless (close $SFH) {
		print STDERR ">>> $0: error closing '$savename': $!\n"; exit(1);
	}

	if ( $testflag ) {
		my $output = `sshd -f $savename -t 2>&1`;
		if ( $output ) {
			print "$output\n";
		}
	}

	if ( $diffflag ) {
		my $output = `diff $savename $confname 2>&1`;
		if ( $output ) {
			print "$output\n";
		}
	}
}


#______________________________________________________________________________
#

# vi: nu ts=4
