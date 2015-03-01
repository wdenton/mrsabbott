#!/usr/bin/perl -w

package MrsAbbott::Config;

use strict;
require Exporter;

$|++;

use vars     qw (@ISA @EXPORT @EXPORT_OK);
@ISA       = qw (Exporter);
@EXPORT    = qw (@titleFields %titleFields
		 $dataSource $userName $password %lcSubClasses
		 @titleArticles @bookFormats
		 @purchaseDays @purchaseMonths @purchaseYears
		 $HTML_HEAD $HTML_FOOT $SEARCH_FORM
		 );
@EXPORT_OK = qw ();

use vars qw($dataSource $userName $password $HTML_HEAD $HTML_FOOT %URL
	    $SEARCH_FORM %lcSubClasses
	    @purchaseDays @purchaseMonths @purchaseYears
	    @titleArticles @bookFormats @titleFields %titleFields);

# Set these variables to the right values for your database type 
# and user and database you've set for the catalogue.

$dataSource = 'DBI:mysql:library';
$userName   = 'marion';
$password   = 'shipoopie';

# Your library's name.
my $libraryName = "Miskatonic University Press Library";

# Admin e-mail address
my $adminEmail = "wtd\@pobox.com";

# Name of lc-subclasses.txt file
my $lcSubClassList = "lc-subclasses.txt";

# ----------

%URL = ('update' => '/cgi-bin/update',
        'title'  => '/cgi-bin/title',
        'search' => '/cgi-bin/search',
);

@titleFields = ('Title ID', 'Article', 'Title', 'Format', 'Edition', 
		'Publisher', 'Call No.', 'ISBN', 'First Printed', 'Published', 
		'Purchase Date', 'Purchase Cost', 'First Line', 'Notes');

%titleFields = ('01id'           => 'Title ID',
		'02article'      => 'Article',
		'03title'        => 'Title',
		'04format'       => 'Format',
		'05edition'      => 'Edition',
		'06publisher'    => 'Publisher',
		'07callNumber'   => 'Call No.',
		'08isbn'         => 'ISBN',
		'09pubFirst'     => 'First Printed',
		'10pubYear'      => 'Published',
		'11purchaseCost' => 'Purchase Cost',
		'12purchaseDate' => 'Purchase Date',
		'13firstLine'    => 'First Line',
		'14notes'        => 'Notes'
		);

@titleArticles = ('', qw(A An The));

# Book formats: mass market, paperback, trade paperback, hardcover,
# LP, CD, comic book.
@bookFormats = ('', qw(MM PB TP HC LP CD CB));

@purchaseYears = ('', (1995..2008));
# 01, 02 ... 12
@purchaseMonths = (('x'), map { (($_ < 10) ? "0" : "") . $_ } (1..12));
@purchaseDays   = (('x'), map { (($_ < 10) ? "0" : "") . $_ } (1..31));



$SEARCH_FORM = qq(
<form action="/cgi-bin/search" method="get">

<table>

<tr>

<td>Title</td>
<td>
<input type="text" size="20" name="title" value="::TITLE::" />
</td>

<td>Author</td>
<td>
<input type="text" size="20" name="author" value="::AUTHOR::" />
</td>

<td>
<input type="submit" name="search" value="Search" />
</td>

</tr>
</table>

</form>

);

my $titleBarSearch = qq(

<form action="/cgi-bin/search" method="get">
Title: <input type="text" size="10" name="title" value="::TITLE::" />
Author: <input type="text" size="10" name="author" value="::AUTHOR::" />
<input type="submit" name="search" value="Search" />
</form>

);

$HTML_HEAD = qq(
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html>
<head>
<title>Mrs. Abbott: $libraryName</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link rev="made" href="mailto:$adminEmail" />
<link rel="stylesheet" type="text/css" href="/css/library.css" />
<!-- link rel="shortcut icon"
      href="http://library/images/favicon.ico" / -->
</head>

<body>

<h1>$libraryName</h1>

<div id="topBar">

<div id="menu">

<a href="/">Home</a> <span> | </span>
<a href="/cgi-bin/search">Search</a> <span> | </span>
<a href="/cgi-bin/update">Add</a> <span> | </span>
<a href="/cgi-bin/series">Series</a> <span> | </span>
<a href="/cgi-bin/pseuds">Pseuds</a> <span> | </span>

</div>

<div id="search">

$titleBarSearch

</div>

</div>

<p>&nbsp;</p>

<hr />

);

$HTML_FOOT = qq(
</body>
</html>
);

# Set up the LC subclasses hash, which search uses to make
# the class and subclass letters more informative.

if (open LC, $lcSubClassList) {

    while (<LC>) {

	next if /^#/;
	next unless /^.*$/;

	chomp;

	# Horrible ugly way to split the lines, but for some reason
	# I couldn't get a ^(\w{1,3}) (.*)/ sort of regex working.
	# Yes, I'm embarrassed.
	my $cut = index $_, " ";
	my $subclass = substr ($_, 0, $cut);
	my $category = substr ($_, $cut + 1);
	$lcSubClasses{$subclass} = $category;

    }

} else {

    print STDERR "Could not open $lcSubClassList";

}

1;
