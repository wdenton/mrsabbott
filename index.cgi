#!/usr/bin/perl -w

use strict;
use lib "cgi-bin";
use MrsAbbott;
use MrsAbbott::Config;

print "Content-type: text/html\n\n";

$HTML_HEAD =~ s/::TITLE:://;
$HTML_HEAD =~ s/::AUTHOR:://;
print $HTML_HEAD;

print<<"BODY";

<h2>Welcome!</h2>

<p>

Welcome to the Miskatonic University Press Library catalogue! Use the 
menu on the left to browse or search the catalogue.

</p>

<p>
Librarian: William Denton
</p>

BODY

print $HTML_FOOT;
