#!/usr/bin/perl -w

package MrsAbbott::Title;

use MrsAbbott::Config;

use strict;
require Exporter;

use vars     qw (@ISA @EXPORT @EXPORT_OK);
@ISA       = qw (Exporter);
@EXPORT    = qw (getTitlesByAuthorID getTitleInfo formatTitle newFormatTitle
    );
@EXPORT_OK = qw ();


sub getTitleInfo {

    # Given a title ID, return all the information about it
    # in a hash.

    my ($titleHashRef, $titleID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password)
	or die "Couldn't connect to database: " . DBI->errstr;

    my $sth = $dbh->prepare(q(SELECT * FROM title WHERE id = ?))
	or die "Couldn't prepare statement: " . $dbh -> errstr;

    $sth -> execute ($titleID)
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

sub getTitlesByAuthorID {

    # Given a reference to a hash, and an author's ID number,
    # make the keys in the hash be the ID numbers of the titles
    # of the books written by that author, and the values
    # of each key will be another hash, containing all the information
    # about that title, keyed to the field names from the title
    # table.  If that makes sense.
    #
    # So you get back
    #  $hash{'1'}{'title'} = 'Title of Book 1'
    #  $hash{'1'}{'publisher'} = 'Signet'
    # etc.

    my ($titleHashRef, $authorID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password)
	or die "Couldn't connect to database: " . DBI->errstr;

    my $sth = $dbh->prepare(q(
SELECT t.* FROM title t, hasWritten h
WHERE h.authorRef = ?
AND h.titleRef = t.id))
	or die "Couldn't prepare statement: " . $dbh -> errstr;

    $sth -> execute ($authorID)
	or die "Couldn't execute statement: " . $sth -> errstr;

    while (my $hashRef = $sth->fetchrow_hashref) {

	# my $id = $hashRef->{'id'};
	# $titleHashRef->{$id} = $hashRef;
	# Or, more compactly but less clearly:
	$titleHashRef->{$hashRef->{'id'}} = $hashRef;

    }

    $sth->finish;
    $dbh->disconnect;

    # The hash referenced by $titleHashRef will be filled up now,
    # and can be seen by the calling function.

    1;

}

sub formatTitle {

    # Given an article (The, A), a title and an edition number,
    # any of which might be undefined, return a nice-looking title.

    my ($article, $title, $edition) = (@_);

    return ((defined $article ? $article . " " : "") .
	    (defined $title  ? $title : "") .
	    (defined $edition ? " (" . $edition . "e)" : ""));

}

sub newFormatTitle {

    my $titleID = shift;

    my %titleHash;
    getTitleInfo (\%titleHash, $titleID);

    return formatTitle ($titleHash{$titleID}{'article'},
			$titleHash{$titleID}{'title'},
			$titleHash{$titleID}{'edition'});

}

1;
