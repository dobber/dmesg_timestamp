#!/usr/bin/env perl
#################################
# Show time with dmesg command  #
#################################

use strict;
#use warnings;
use Getopt::Std;
use File::Basename;

my $basename = basename ($0);
my $filename="/var/log/dmesg";
my $follow=0;
my $now = time();
my $uptime = `cut -d"." -f1 /proc/uptime`;
my $t_now = $now - $uptime;
my @dmesg;
my @dmesg_new=();
 
our ($opt_h, $opt_f);

# print usage
sub print_usage () {
    print "Usage: $basename [OPTION] [FILE]\n";
    print "Show dmesg with normalized times.\n";
    print "    -f    output appended data as the file grows\n";
    print "    -h    show this help screen\n";
    print "\nIf FILE is given, read it instead of 'dmesg'.\n";
}

getopts('hf');

if ($opt_h == "1") {
    $opt_h='';
    print_usage();
    exit (0);
}

if ($opt_f == "1") {
    $opt_f='';
    $follow=1;
}

# open the file and read the lines
sub loop_stream {
    while (<FH>) {
	chomp( $_ );
	if( $_ =~ m/\[\s*(\d+)\.(\d+)\](.*)/i ) {
	    # now - uptime + sekunden
	    my $t_time = format_time( $t_now + $1 );
	    print "[$t_time] $3\n";
	}
    }
}

# open file
sub open_file {
    $filename=$_[0];
    open (FH,'<',$filename) or die "Error opening $filename:\n$!";
    if ($follow == 1) {
	while (42) {
	    loop_stream();
	    sleep 1;
	    seek FH, 0, 1;
	}
    } else {
	loop_stream();
    }
    close(FH);
}

# format time
sub format_time {
    my @time = localtime $_[0];
    $time[4]+=1;    # Adjust Month
    $time[5]+=1900;    # Adjust Year
    return sprintf '%4i-%02i-%02i %02i:%02i:%02i', @time[reverse 0..5];
}

# main part
if ($#ARGV == 0) {
    $filename=$ARGV[0];
    open_file($filename);
} else {
    open_file($filename);
}
