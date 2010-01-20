#/bin/bash

# DROP THE EXISTING DB (are you sure)
dropdb -U postgres tmcpe

# MAKE THE NEW ONE (and make it spatially enabled)
createdb -U postgres tmcpe
createlang -U postgres plpgsql tmcpe
psql -U postgres -d tmcpe -f /usr/share/postgresql-8.4/contrib/postgis.sql
psql -U postgres -d tmcpe -f /usr/share/postgresql-8.4/contrib/spatial_ref_sys.sql

# NOW INSERT THE ACTIVITY LOG DATA
psql -U postgres tmcpe < activity-log-data/ct-al-data-pg.sql 2>&1 | cat > /dev/null

psql -U postgres tmcpe -c 'CREATE SCHEMA actlog'
psql -U postgres tmcpe -c 'ALTER TABLE d12_activity_log SET SCHEMA actlog'

# grab tbmap.tvd and tbmap.vds_view from osm
psql -U postgres tmcpe -c 'CREATE SCHEMA tbmap'
ssh crindt@localhost pg_dump -U VDSUSER --inserts -t tbmap.tvd  -t tbmap.vds_segment_geometry -t tbmap.vds_view osm > tbmap.sql
psql -U postgres tmcpe < tbmap.sql

# create the sigalerts locations table
psql -U postgres tmcpe < sql/actlog/major-incidents-actlog.sql

