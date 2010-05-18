rm lib/TMCPE/ActivityLog/Schema/*.pm && perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("TMCPE::ActivityLog::Schema", { debug => 1, db_schema => "actlog" }, [ "dbi:Pg:dbname=tmcpe_test;host=localhost;user=TMCPUSER" ])' && (for f in lib/TMCPE/ActivityLog/Schema/*.pm; do sed 's/table("/table("actlog./g' $f > $f-hold && mv $f-hold $f; done )


rm lib/TBMAP/Schema/*.pm && perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("TBMAP::Schema", { debug => 1, db_schema => "tbmap" }, [ "dbi:Pg:dbname=tmcpe_test;host=localhost;user=TMCPUSER" ])' && (for f in lib/TBMAP/Schema/*.pm; do sed 's/table("/table("tbmap./g' $f > $f-hold && mv $f-hold $f; done )

rm lib/TMCPE/Schema/*.pm && perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("TMCPE::Schema", { debug => 1, db_schema => "tmcpe" }, [ "dbi:Pg:dbname=tmcpe_test;host=localhost;user=TMCPUSER" ])' && (for f in lib/TMCPE/Schema/*.pm; do sed 's/table("/table("tmcpe./g' $f > $f-hold && mv $f-hold $f; done )

rm lib/SpatialVds/Schema/*.pm && perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("SpatialVds::Schema", { debug => 1, db_schema => "public" }, [ "dbi:Pg:dbname=spatialvds;host=localhost;user=VDSUSER;password=VDSPASSWORD" ])'
