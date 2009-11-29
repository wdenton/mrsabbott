#!/usr/local/bin/perl -w

use strict;
use DBI;
use CGI qw(escape unescape);

use lib "/usr/local/www/server/library/cgi-bin";
use MrsAbbott;

my $authorID = '69';
my ($firstName, $lastName) = getAuthorInfo ($authorID);
my $authorName = formatAuthorName ($firstName, $lastName);

my $newFirstName = 'John';
my $newLastName  = 'Smith';
my $newAuthorName = formatAuthorName ($newFirstName, $newLastName);

my $isKnownID = findAuthorByNames ($newFirstName, $newLastName);
my $rowsAffected;

if ($isKnownID) {
    
    print "<p>$newAuthorName is known (ID $isKnownID).\n", 
    $rowsAffected = replaceAuthor ($authorID, $isKnownID);
    $authorID = $isKnownID;

} else {

    print "<p>$newAuthorName is a new author! ";
    $rowsAffected = editAuthorName 
       ($authorID, $newFirstName, $newLastName);

}

print "Replaced ($rowsAffected rows affected).\n";
print "$authorName changed to <b>$newAuthorName</b>.</p>\n";

