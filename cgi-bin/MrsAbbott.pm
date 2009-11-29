#!/usr/bin/perl -w

package MrsAbbott;

use MrsAbbott::Config;

use strict;
require Exporter;

use vars     qw (@ISA @EXPORT @EXPORT_OK);
@ISA       = qw (Exporter);
@EXPORT    = qw (formatHashedTitle printBookForm byNumber
		 );
@EXPORT_OK = qw ();

sub printBookForm {

    # There are two places where we need to print out the form that's
    # used to edit the information about a book: where new titles are
    # entered from scratch, and where existing titles are edited.  In
    # the first case we're just printing out a blank form, and in the
    # second we want to populate the fields with their already known
    # values.  Since it's done twice, and since this bit is the most
    # important form in the catalogue and it'll be tweaked a fair bit
    # and we don't want to have to tweak it in two places, I made
    # this one place where it's generated.  
    #
    # Call this function with a reference to a title hash if you want
    # to edit a known book, or with no argument if you're doing a brand
    # new title.
    # 
    # The old way this used to be done was just to print out
    # a simple form, with each field being the same length.
    # 
    # For the sake of reference, here's the old code:
    #
    # print "<table border=0>\n";
    #
    # # Now we do the form so you can edit the various fields about a
    # # book.  Got to do it this way again, to get the fields listed in
    # # the right order.
    #
    # foreach my $key (sort keys %titleFields) {
    #
    #     (my $keyname = $key) =~ s/^\d+//;
    #
    #     if ($keyname eq 'id') {
    #         # This has to be passed on to the next step,
    #  	      # but it's not a field you can edit.
    #  	      print qq(<input type="hidden" name="id" value="$titleID">\n);
    #  	      next;
    #     }
    #
    #     print "<tr>\n";
    #     print "<td>$titleFields{$key}</td>\n";
    #
    #     print "<td>";
    #     print qq(<input type="text" size="40" name="$keyname");
    #     print defined $titleHash{$titleID}{$keyname} ? 
    #  	      qq( value="$titleHash{$titleID}{$keyname}">) : ">";
    #     print "</td>\n";
    #
    #     print "\n";
    #     print "</tr>\n";
    #
    # }
    #
    # print "</table>\n";

    # All in all I think this is an ugly mess, but:
    # - there's only place where the entry form is printed
    # - it does a smart job of filling in values when editing a book
    # - there must be a couple more things

    my $titleInfoHashRef = shift;

    my $titleID;

    # Make the pop-up for the Article field.
    my $articleOptions = qq(<select name="article">);
    foreach my $article (@titleArticles) { 
  	$articleOptions .= qq(<option value="$article");
  	$articleOptions .= " selected" if 
  	   (defined $titleInfoHashRef->{'article'} && 
	   $article eq $titleInfoHashRef->{'article'});
  	$articleOptions .= "> $article</option>\n";
    }
    $articleOptions .= "</select>";

    # And the pop-up for the Format field.
    my $formatOptions = qq(<select name="format">\n);
    foreach my $format (@bookFormats) { 
	$formatOptions .= qq(<option value="$format");
	$formatOptions .= " selected" if 
  	   (defined $titleInfoHashRef->{'format'} &&
	    $format eq $titleInfoHashRef->{'format'});
	$formatOptions .= qq"> $format</option>\n";
    }
    $formatOptions .= "</select>";

    my %values;
    foreach my $key (sort keys %titleFields) {

       (my $keyname = $key) =~ s/^\d+//;
       next if $keyname eq 'article';
       next if $keyname eq 'format';
       $values{$keyname} = defined $titleInfoHashRef->{$keyname} ?
	  qq( value="$titleInfoHashRef->{$keyname}") : "";

   }

    print "<pre>\n";

    if (! defined $titleInfoHashRef->{'id'}) {
	# Being called empty, so it's a new book, so we ask
	# for the author's name.
	print <<"AUTHOR";
Author\'s
First Name    <input type="text" size="20" name="firstName" />
Last Name     <input type="text" size="20" name="lastName" />
AUTHOR
    } else {
	# We need to pass on the ID number.
	print qq(<input type="hidden" name="id" 
		 value="$titleInfoHashRef->{'id'}">\n);
    }

   print <<"FORM";
Title         $articleOptions <input type="text" size="35" name="title" $values{'title'} />
Edition       <input type="text" size="4" name="edition" $values{'edition'} />
Format        $formatOptions
Publisher     <input type="text" size="25" name="publisher" $values{'publisher'} />
Call Number   <input type="text" size="25" name="callNumber" $values{'callNumber'} />
ISBN          <input type="text" size="13" maxlength="13" name="isbn" $values{'isbn'} />
First Printed <input type="text" size="4" maxlength="4" name="pubFirst" $values{'pubFirst'} />
This Edition  <input type="text" size="4" maxlength="4" name="pubYear" $values{'pubYear'} />
Purchase Cost <input type="text" size="10" name="purchaseCost" $values{'purchaseCost'} /> 
Purchase Date <input type="text" size="10" maxlength="10" name="purchaseDate" $values{'purchaseDate'} /> (YYYY-MM-DD)
First Line    <input type="text" size="40" name="firstLine" $values{'firstLine'} />
Notes         <input type="text" size="40" name="notes" $values{'notes'} />
</pre>
FORM

}


1;
