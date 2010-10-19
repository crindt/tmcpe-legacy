package OSM::Schema::GeometryColumns;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("geometry_columns");
__PACKAGE__->add_columns(
  "f_table_catalog",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 256,
  },
  "f_table_schema",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 256,
  },
  "f_table_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 256,
  },
  "f_geometry_column",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 256,
  },
  "coord_dimension",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "srid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "type",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 30,
  },
);
__PACKAGE__->set_primary_key(
  "f_table_catalog",
  "f_table_schema",
  "f_table_name",
  "f_geometry_column",
);
__PACKAGE__->add_unique_constraint(
  "geometry_columns_pk",
  [
    "f_table_catalog",
    "f_table_schema",
    "f_table_name",
    "f_geometry_column",
  ],
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:47:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P6BtNwL9NQdTVRQbGfQN5g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
