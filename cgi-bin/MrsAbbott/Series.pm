#!/usr/bin/perl -w

package MrsAbbott::Series;

use MrsAbbott::Config;

use strict;
require Exporter;

use vars     qw (@ISA @EXPORT @EXPORT_OK);
@ISA       = qw (Exporter);
@EXPORT    = qw (getSeriesByTitleID getSeriesInfo
		 getSeriesName getTitlesBySeriesID listSeries
		 );
@EXPORT_OK = qw ();


sub getSeriesByTitleID {

    my ($seriesHashRef, $titleID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or die "Couldn't connect to database: " . DBI->errstr;  

    my $sth = $dbh->prepare(q(
SELECT s.name, s.id, i.placeInSeries
FROM series s, isInSeries i
WHERE i.titleRef = ?
AND s.id = i.seriesRef))
      or die "Couldn't prepare statement: " . $dbh -> errstr;   

    $sth -> execute ($titleID)
       or die "Couldn't execute statement: " . $sth -> errstr;

    while (my $hashRef = $sth->fetchrow_hashref) {
	$seriesHashRef->{$hashRef->{'id'}} = $hashRef;
    }

    $sth->finish;
    $dbh->disconnect;

    1;

}


sub getTitlesBySeriesID {

    # Given a series ID, fill a hash with all title information
    # about all titles in that series.

    my ($titleHashRef, $seriesID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or die "Couldn't connect to database: " . DBI->errstr;  

    my $sth = $dbh->prepare(q(
SELECT t.* FROM title t, isInSeries i
WHERE i.seriesRef = ?
AND i.titleRef = t.id))
       or die "Couldn't prepare statement: " . $dbh -> errstr;   

    $sth -> execute ($seriesID)
       or die "Couldn't execute statement: " . $sth -> errstr;

    while (my $hashRef = $sth->fetchrow_hashref) {
	$titleHashRef->{$hashRef->{'id'}} = $hashRef;
    }

    $sth->finish;
    $dbh->disconnect;

    # The hash referenced by $titleHashRef will be filled up now,
    # and can be seen by the calling function.

    1;

}

sub listSeries {

    # Given a hash, return it filled with keys being the ID
    # numbers of series, and their values being the names.
    # This is great if you need a list of all the series known
    # about.

    my $seriesHashRef = shift;

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or die "Couldn't connect to database: " . DBI->errstr;  

    my $sth = $dbh->prepare(q(SELECT * FROM series))
       or die "Couldn't prepare statement: " . $dbh -> errstr;   

    $sth -> execute
       or die "Couldn't execute statement: " . $sth -> errstr;

    while (my $hashRef = $sth->fetchrow_hashref) {
	$seriesHashRef->{$hashRef->{'id'}} = $hashRef->{'name'};
    }

    $sth->finish;
    $dbh->disconnect;

}


sub getSeriesName {

    # Given a series ID, return the name of that series.

    my ($seriesID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or die "Couldn't connect to database: " . DBI->errstr;  

    my $sth = $dbh->prepare(q(SELECT * FROM series WHERE id = ?))
       or die "Couldn't prepare statement: " . $dbh -> errstr;   

    $sth -> execute ($seriesID)
       or die "Couldn't execute statement: " . $sth -> errstr;

    # There will be only one line per seriesID, so we don't need to loop.
    my $hashRef = $sth->fetchrow_hashref;

    my $seriesName = $hashRef->{'name'};

    $sth->finish;
    $dbh->disconnect;

    return $seriesName;

}    


sub getSeriesInfo {

    # Given a series ID, fill in a hash with information from the
    # series table.  Note that the has will be a little different
    # from author and title hashes, because the main keys will
    # be the placeInSeries numbers, not the isInSeries.id numbers.
    # This is so it's easy to see where in the series each book
    # falls.

    my ($seriesHashRef, $seriesID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or die "Couldn't connect to database: " . DBI->errstr;  

    my $sth = $dbh->prepare(q(SELECT * FROM isInSeries WHERE seriesRef = ?))
       or die "Couldn't prepare statement: " . $dbh -> errstr;   

    $sth -> execute ($seriesID)
       or die "Couldn't execute statement: " . $sth -> errstr;

    while (my $hashRef = $sth->fetchrow_hashref) {
	$seriesHashRef->{$hashRef->{'placeInSeries'}} = $hashRef;
    }

    $sth->finish;
    $dbh->disconnect;

    1;

}


1;
