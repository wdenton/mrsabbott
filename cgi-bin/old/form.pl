#!/usr/local/bin/perl -w

use strict;
use DBI;
use CGI qw(escape unescape);

use lib "/usr/local/www/server/library/cgi-bin";
use MrsAbbott;

my %titleHash;

getTitleInfo (\%titleHash, '3');

printBookForm (\%{$titleHash{'3'}});
# printBookForm;
