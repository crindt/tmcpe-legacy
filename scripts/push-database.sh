#!/bin/bash

new=tmcpe_`date +"%Y_%m_%d_%H_%M_%S"`

echo psql     -h localhost -U postgres -p 5433 -c \"ALTER DATABASE tmcpe RENAME TO $new\"

echo createdb -h localhost -U postgres -p 5433 tmcpe

echo "pg_dump -U postgres tmcpe_test -Fc | pg_restore -h localhost -U postgres -p 5433 -Fc -d tmcpe"