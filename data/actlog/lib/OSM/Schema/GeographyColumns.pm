package OSM::Schema::GeographyColumns;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("geography_columns");
__PACKAGE__->add_columns(
  "f_table_catalog",
  { data_type => "name", default_value => undef, is_nullable => 1, size => 64 },
  "f_table_schema",
  { data_type => "name", default_value => undef, is_nullable => 1, size => 64 },
  "f_table_name",
  { data_type => "name", default_value => undef, is_nullable => 1, size => 64 },
  "f_geography_column",
  { data_type => "name", default_value => undef, is_nullable => 1, size => 64 },
  "coord_dimension",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "srid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "type",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:47:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c4WaiqukhJSyZOsqTqtxIg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
