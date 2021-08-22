#!/usr/bin/perl -w

package MrsAbbott::Pseudonym;

use MrsAbbott::Config;

use strict;
require Exporter;

use vars     qw (@ISA @EXPORT @EXPORT_OK);
@ISA       = qw (Exporter);
@EXPORT    = qw (isPseudonymFor listPseudonymsOf connectRealNameToPseudonym
		 );
@EXPORT_OK = qw ();


sub isPseudonymFor {

    # Given an author ID, return a list of all ID numbers of
    # all authors who use that name as a pseudonym.
    #
    # So Richard Stark  returns (Donald E. Westlake)
    #    Brett Halliday returns (Davis Dresser, another, more)

    my ($authorID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password, {mysql_enable_utf8mb4 => 1})
	or die "Couldn't connect to database: " . DBI->errstr;

    my $sth = $dbh->prepare(q(
SELECT * FROM pseudonyms WHERE pseudoNameRef = ?))
	or die "Couldn't prepare statement: " . $dbh -> errstr;

    $sth -> execute ($authorID)
	or die "Couldn't execute statement: " . $sth -> errstr;

    my @realNameIDs;

    while (my $hashRef = $sth->fetchrow_hashref) {
	push (@realNameIDs, $hashRef->{'realNameRef'});
    }


    $sth->finish;
    $dbh->disconnect;

    return (@realNameIDs);


}

sub listPseudonymsOf {

    # Given an author ID, return ID numbers for all names
    # this author uses as pseudonyms.

    my ($realID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password, {mysql_enable_utf8mb4 => 1})
	or die "Couldn't connect to database: " . DBI->errstr;

    my $sth = $dbh->prepare(q(
SELECT * FROM pseudonyms WHERE realNameRef = ?))
	or die "Couldn't prepare statement: " . $dbh -> errstr;

    $sth -> execute ($realID)
	or die "Couldn't execute statement: " . $sth -> errstr;

    my @pseudIDs;

    while (my $hashRef = $sth->fetchrow_hashref) {
	push (@pseudIDs, $hashRef->{'pseudoNameRef'});
    }


    $sth->finish;
    $dbh->disconnect;

    return (@pseudIDs);

}

sub connectRealNameToPseudonym {

    # Given an author ID and a title ID, make the proper entry
    # in the hasWritten table connecting the two.

    my ($realAuthorID, $pseudAuthorID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password, {mysql_enable_utf8mb4 => 1})
	or die "Couldn't connect to database: " . DBI->errstr;

    $dbh->do(qq(
INSERT INTO pseudonyms (realNameRef, pseudoNameRef)
VALUES ($realAuthorID, $pseudAuthorID)))
        or die "Couldn't prepare statement: " . $dbh -> errstr;

    my $hasWrittenID = $dbh->{'mysql_insertid'};

    $dbh->disconnect;

    return $hasWrittenID;

}

1;
