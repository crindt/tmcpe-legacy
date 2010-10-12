psql -U postgres tmcpe_test -f reset-incident-data.sql

sh regenerate-schemas.sh
