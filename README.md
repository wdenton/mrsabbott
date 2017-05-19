HISTORY
-------

I wrote this early in 2001 so I could manage my personal library. That was BEFORE I went to library school.  There were a couple of programs out there for managing personal libraries, but none suited my needs, so I wrote this.  I had never taken a cataloguing course, knew nothing about MARC records, and wasn't a very good programmer.  (The first two changed, the third is still true.)

If I were doing this again I'd do it very differently, or I might not do it at all.  I might use LibraryThing to manage my collection.  If I wrote something for myself I'd use Python or Ruby with a good web framework.  But I did this in 2001, before any of that, and I've used it ever since, and it does its job: I know what I have and where it is.

I don't expect any interest in this, but I'm putting it on GitHub to make my life easier, and because there's no reason to keep it private.

Warning:  This is not good Perl.

HOW TO SET IT UP
----------------

Since I don't expect anyone to actually run this these instructions are not overly helpful.

How to set up your web server
-----------------------------

Set up the hostname 'library' in your DNS.  I use /etc/hosts and have
it at the same IP number as my local machine. Because Apache will be
configured to look for a virtual host with that name, this will work:

   <VirtualHost *:80>
   	ServerName library
   	ServerAdmin webmaster@localhost

   	DocumentRoot /var/www/library/
   	<Directory /var/www/library/>
   		AddHandler cgi-script .cgi
   		Options ExecCGI FollowSymLinks MultiViews
   		DirectoryIndex index.cgi
   		AllowOverride None
   		Order allow,deny
   		Allow from all
   	</Directory>

   	ScriptAlias /cgi-bin/ /var/www/library/cgi-bin/
   	<Directory "/var/www/library/cgi-bin">
   		AllowOverride None
   		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
   		Order allow,deny
   		Allow from all
   	</Directory>

   	ErrorLog /var/log/apache2/library-error.log

   	# Possible values include: debug, info, notice, warn, error, crit,
   	# alert, emerg.
   	LogLevel warn

   	CustomLog /var/log/apache2/library-access.log combined
   </VirtualHost>

Put all of the Mrs. Abbott files into /var/www/library, set up Apache,
run 'apache2ctl restart', and everything will probably be OK.  If not
then a bit of fiddling will do it if you keep at it, I'm sure.

@INC
----

In Ubuntu 17.04 Apache stopped seeing the MrsAbbott module in the =cgi-bin= directory, so I brute forced it:

   sudo cp -r ~/src/mrsabbott/cgi-bin/MrsAbbott* /etc/perl/

How to set up the database
--------------------------

Of course you'll also need to set up the database before you can
actually add or view any books.  First, create the database in MySQL:

   # mysql -u root
   > create user 'marion'@'localhost' identified by 'XXXXXX';
   > create database library;
   > grant all privileges on library.* to marion;
   > quit;

Now create the tables and initial data.

TODO: [Put the default insert script here]
