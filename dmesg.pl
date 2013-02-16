#!/usr/bin/perl
#################################
# Show time with dmesg command  #
#                               #
# Author : Djerfy               #
# Mail : djerfy@gmail.com       #
# Site : www.djerfy.com         #
# GitHub : github.com/djerfy    #
#################################

use strict;
use warnings;

my @dmesg_new = ();
my @dmesg = `/bin/dmesg`;
my $now = time();
my $uptime = `cut -d"." -f1 /proc/uptime`;
my $t_now = $now - $uptime;

sub format_time {
 my @time = localtime $_[0];
 $time[4]+=1;    # Adjust Month
 $time[5]+=1900;    # Adjust Year
 return sprintf '%4i-%02i-%02i %02i:%02i:%02i', @time[reverse 0..5];
}

foreach my $line ( @dmesg )
{
 chomp( $line );
 if( $line =~ m/\[\s*(\d+)\.(\d+)\](.*)/i )
 {
 # now - uptime + sekunden
 my $t_time = format_time( $t_now + $1 );
 push( @dmesg_new , "[$t_time] $3" );
 }
}

print join( "\n", @dmesg_new );
print "\n";
