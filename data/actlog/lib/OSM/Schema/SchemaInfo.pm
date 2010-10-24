package OSM::Schema::SchemaInfo;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("schema_info");
__PACKAGE__->add_columns(
  "version",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("version");
__PACKAGE__->add_unique_constraint("pk_schema_info", ["version"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zqr/9z2nAPh8gjazxELVAQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
