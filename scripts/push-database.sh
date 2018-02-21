#!/bin/bash

new=tmcpe_`date +"%Y_%m_%d_%H_%M_%S"`

psql     -h ***REMOVED*** -U postgres -p 5433 -c "ALTER DATABASE tmcpe RENAME TO $new" \
    || ( echo "Failed renaming tmcpe database to $new" && exit 1 )

createdb -h ***REMOVED*** -U postgres -p 5433 tmcpe \
    || ( echo "Failed creating new tmcpe database" && exit 1 )

(pg_dump -U postgres tmcpe_test -Fc | pg_restore -h ***REMOVED*** -U postgres -p 5433 -Fc -d tmcpe) \
    || ( echo "Failed duplicating database" && exit 1
