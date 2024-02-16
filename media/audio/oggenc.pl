#!/usr/bin/perl
#
# oggenc wrapper to lowercase-ize all song info
#

foreach(@ARGV){
    # print $_, "\n";
    if ( ($_ ne "-Q") and ($_ ne "-B") and ($_ ne "-C") and ($_ ne "-R") and ($_ ne "-M") and ($_ ne "-X") and ($_ ne "-P") and ($_ ne "-N") and ($_ ne "-G") ){
	$_ = lc($_);
	# print "*** ", $_, " ***\n";
    }
    $_ = "\"$_\"";
}
# print "\n\n";

$blah = join(" ", @ARGV);
# print $blah, "\n";

`oggenc $blah`;
