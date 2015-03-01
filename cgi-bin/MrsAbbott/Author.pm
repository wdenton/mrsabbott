#!/usr/bin/perl -w

package MrsAbbott::Author;

use MrsAbbott::Config;

use strict;
require Exporter;


use vars     qw (@ISA @EXPORT @EXPORT_OK);
@ISA       = qw (Exporter);
@EXPORT    = qw (getAuthorsByTitleID getAuthorInfo formatAuthorName 
		 insertAuthor connectAuthorToTitle findAuthorByNames
		 editAuthorName replaceAuthor deleteAuthor
		 );
@EXPORT_OK = qw ();

sub getAuthorInfo {

    # Given an authorID, return (firstName, lastName).

    my ($authorID) = (@_);
    my $authorHashRef;

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or print "<strong>Error</strong> " . 
                "Couldn't connect to database: " . DBI->errstr;  

    my $sth = $dbh->prepare(q(SELECT * FROM author WHERE id = ?))
       or print "<strong>Error</strong> " .
                "Couldn't prepare statement: " . $dbh -> errstr;   

    $sth -> execute ($authorID)
       or print "<strong>Error</strong> " .
                "Couldn't execute statement: " . $sth -> errstr;

    while (my $hashRef = $sth->fetchrow_hashref) {
	$authorHashRef->{$hashRef->{'id'}} = $hashRef;
    }

    $sth->finish;
    $dbh->disconnect;

    return ($authorHashRef->{$authorID}{'firstName'},
	    $authorHashRef->{$authorID}{'lastName'});

}


sub getAuthorsByTitleID {

    # Given a title ID, returns a list of IDs of authors
    # who wrote the book.  Suitable for feeding into
    # getAuthorInfo and formatAuthorName.

    my $titleID = shift;
    my @listOfAuthors;

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or print "<strong>Error</strong> " .
                "Couldn't connect to database: " . DBI->errstr;  

    my $sth = $dbh->prepare(q(
SELECT a.id FROM author a, hasWritten h 
WHERE h.titleRef = ?
AND h.authorRef = a.id))
       or print "<strong>Error</strong> " .
                "Couldn't prepare statement: " . $dbh -> errstr;   

    $sth -> execute ($titleID)
       or print "<strong>Error</strong> " .
                "Couldn't execute statement: " . $sth -> errstr;

    while (my $hashRef = $sth->fetchrow_hashref) {
	push @listOfAuthors, $hashRef->{'id'};
    }

    $sth->finish;
    $dbh->disconnect;

    # The hash referenced by $titleHashRef will be filled up now,
    # and can be seen by the calling function.

    return @listOfAuthors;
    
}


sub findAuthorByNames {

    # Given a first name and a last name, return the
    # ID number of the author matching those names,
    # if one exists.

    my ($firstName, $lastName) = (@_);

    my $dbQuery = "SELECT id FROM author WHERE ";
    $dbQuery .= qq(firstName = "$firstName" AND ) if $firstName;
    $dbQuery .= qq(lastName = "$lastName");

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or print "<strong>Error</strong> " .
                "Couldn't connect to database: " . DBI->errstr;  

    my $sth = $dbh->prepare($dbQuery)
       or print "<strong>Error</strong> " .
                "Couldn't prepare statement: " . $dbh -> errstr;   

    $sth -> execute 
       or print "<strong>Error</strong> " .
                "Couldn't execute statement: " . $sth -> errstr;

    my @authorResults = $sth -> fetchrow_array();	    
    
    $sth->finish;
    $dbh->disconnect;

    return $authorResults[0];

}

sub insertAuthor {

    my ($firstName, $lastName) = (@_);

    $firstName = "NULL" unless defined $firstName;
    $lastName  = "NULL" unless defined $lastName;

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or print "<strong>Error</strong> " .
                "Couldn't connect to database: " . DBI->errstr;  

    $firstName = $dbh->quote($firstName);
    $lastName  = $dbh->quote($lastName);

    $dbh->do(qq(
INSERT INTO author (firstName, lastName) VALUES ($firstName, $lastName)))
        or print "<strong>Error</strong> " . "Couldn't prepare statement: " . $dbh -> errstr;   
    
    my $newAuthorID = $dbh->{'mysql_insertid'};

    $dbh->disconnect;

    return $newAuthorID;

}


sub editAuthorName {

    # Given the ID number of an existing author and a new
    # first name and last name, change the names of that ID
    # to the new names.  Just a basic edit on an existing
    # author's name, to be used when the new name does not
    # already exist in the catalogue.

    my ($authorID, $firstName, $lastName) = (@_);

    $firstName = "NULL" unless defined $firstName;
    $lastName  = "NULL" unless defined $lastName;

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or print "<strong>Error</strong> " .
                "Couldn't connect to database: " . DBI->errstr;  

    $firstName = $dbh->quote($firstName);
    $lastName  = $dbh->quote($lastName);

    my $rowsAffected = $dbh->do(qq(
UPDATE author SET firstName=$firstName, lastName=$lastName
WHERE id = '$authorID'))
        or print "<strong>Error</strong> " .
	         "Couldn't prepare statement: " . $dbh -> errstr;   
    
    $dbh->disconnect;

    return $rowsAffected;

}


sub replaceAuthor {

    # This is called when an author's name is being changed but
    # the new, corrected, name is already in the catalogue.
    # All references to the old name's ID will be changed to
    # the new name's ID.  

    my ($oldAuthorID, $newAuthorID) = (@_);
 
    my $dbh = DBI->connect($dataSource, $userName, $password)
       or print "<strong>Error</strong> " .
                "Couldn't connect to database: " . DBI->errstr;  

    my $rowsAffected = $dbh->do(qq(
UPDATE hasWritten SET authorRef=$newAuthorID WHERE authorRef = '$oldAuthorID'))
        or print "<strong>Error</strong> " .
	         "Couldn't prepare statement: " . $dbh -> errstr;   

    # I haven't actually tested this pseudonym stuff.

    # Now do the pseudonyms.
    $dbh->do(qq(
UPDATE pseudonyms SET realNameRef=$newAuthorID
WHERE realNameRef = '$oldAuthorID'))
        or print "<strong>Error</strong> " .
	         "Couldn't prepare statement: " . $dbh -> errstr;   

    $dbh->do(qq(
UPDATE pseudonyms SET pseudoNameRef=$newAuthorID
WHERE pseudoNameRef = '$oldAuthorID'))
        or print "<strong>Error</strong> " .
	         "Couldn't prepare statement: " . $dbh -> errstr;   
    
    $dbh->disconnect;

    deleteAuthor ($oldAuthorID);

    return $rowsAffected;

}


sub deleteAuthor {

    # Given an ID number, delete that author from the author table.

    my ($authorID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or print "<strong>Error</strong> " .
                "Couldn't connect to database: " . DBI->errstr;  

    my $rowsAffected = $dbh->do(qq(
DELETE FROM author WHERE id = '$authorID'))
        or print "<strong>Error</strong> " .
	         "Couldn't prepare statement: " . $dbh -> errstr;   
    
    $dbh->disconnect;

    return $rowsAffected;

}

sub formatAuthorName {

    # Given a first name and a last name (either of which might
    # be undefined), return a nice-looking string containing
    # the name.  If $lastFirst is defined, the name wil come
    # back with the last name first.

    my ($firstName, $lastName, $lastFirst) = (@_);

    if ($lastFirst) { # Last name first: Farnol, Jeffery

	return ((defined $lastName  ? $lastName : "") .
		(length $firstName ? ", ". $firstName : ""));

    } else { # Jeffery Farnol

	return ((defined $firstName ? $firstName . " " : "") .
		(defined $lastName  ? $lastName : ""));


    }

}

sub connectAuthorToTitle {

    # Given an author ID and a title ID, make the proper entry
    # in the hasWritten table connecting the two.

    my ($authorID, $titleID) = (@_);

    my $dbh = DBI->connect($dataSource, $userName, $password)
       or print "<strong>Error</strong> " .
                "Couldn't connect to database: " . DBI->errstr;  

    $dbh->do(qq(
INSERT INTO hasWritten (authorRef, titleRef) VALUES ($authorID, $titleID)))
        or print "<strong>Error</strong> " .
	         "Couldn't prepare statement: " . $dbh -> errstr;   
    
    my $hasWrittenID = $dbh->{'mysql_insertid'};

    $dbh->disconnect;

    return $hasWrittenID;
    


}

1;
