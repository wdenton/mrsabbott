#!/bin/sh

DATE=`date "+%Y%m%d"`

rm -f library-$DATE.sql.gz

mysqldump -u marion -p -c --add-drop-table library > library-$DATE.sql
gzip library-$DATE.sql
