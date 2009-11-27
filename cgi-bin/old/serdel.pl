#!/usr/local/bin/perl -w

use strict;
use DBI;
use CGI qw(escape);

use lib "/usr/local/www/server/library/cgi-bin";
use MrsAbbott;


my $titleID = 51;

my %seriesHash;

getSeriesByTitleID (\%seriesHash, $titleID);

foreach my $a (keys %seriesHash) {

    print "$a: $seriesHash{$a}\n";

}
