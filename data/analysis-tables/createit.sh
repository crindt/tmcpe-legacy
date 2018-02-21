perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("SpatialVds::Schema", { debug => 1 }, [ "dbi:Pg:dbname=spatialvds;host=***REMOVED***;user=VDSUSER;password=VDSPASSWORD;port=5432" ])'
perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("TMCPE::Schema", { debug => 1, db_schema => "tmcpe" }, [ "dbi:Pg:dbname=tmcpe;host=localhost;user=TMCPEUSER" ])'
perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("CT_AL::Schema", { debug => 1, db_schema => "actlog" }, [ "dbi:Pg:dbname=tmcpe;host=localhost;user=TMCPEUSER" ])'

