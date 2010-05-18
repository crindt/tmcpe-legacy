perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("Caltrans::ActivityLog::Schema", { debug => 1 }, [ "dbi:mysql:dbname=actlog;host=trantor.its.uci.edu;user=ALUSER ;password=ALPASSWORD;port=3366" ])'
perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./lib -e 'make_schema_at("TMCPE::ActivityLog::Schema", { debug => 1, db_schema => "actlog" }, [ "dbi:Pg:dbname=tmcpe_test;host=localhost;user=TMCPUSER" ])'

