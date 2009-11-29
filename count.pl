#!/usr/bin/perl

use strict;
use DBI;

use lib "cgi-bin";
use MrsAbbott;
use MrsAbbott::Config;
use MrsAbbott::Author;
use MrsAbbott::Title;

my %countHash;

my $dbh = DBI->connect($dataSource, $userName, $password)
   or die "Couldn't connect to database: " . DBI->errstr;  

my $sth = $dbh->prepare(q(
SELECT id, firstName, lastName FROM author ORDER BY lastName))
   or die "Couldn't prepare statement: " . $dbh -> errstr;   

$sth -> execute
   or die "Couldn't execute statement: " . $sth -> errstr;

while (my $hashRef = $sth->fetchrow_hashref) {

    my $authorID = $hashRef->{'id'};
    my $authorName = formatAuthorName ($hashRef->{'firstName'},
				       $hashRef->{'lastName'});

    my %titleHash;

    getTitlesByAuthorID (\%titleHash, $authorID);

    # print "$authorID\t$authorName\t\t", scalar keys %titleHash, "\n";
    my $number = scalar keys %titleHash;
    # print "$number\t$authorName\n";

    push @{$countHash{$number}}, $authorName;

}

$sth->finish;
$dbh->disconnect;

foreach my $number (sort {$b <=> $a} keys %countHash) {
    last if $number < 10;
    print "$number:";
    # print join ("; ", @{$countHash{$number}});
    foreach my $name (sort {$a cmp $b} @{$countHash{$number}}) {
	print "\t$name\n";
    }
}
