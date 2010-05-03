package SpatialVds::Schema::SpatialRefSys;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("spatial_ref_sys");
__PACKAGE__->add_columns(
  "srid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "auth_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 256,
  },
  "auth_srid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "srtext",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 2048,
  },
  "proj4text",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 2048,
  },
);
__PACKAGE__->set_primary_key("srid");
__PACKAGE__->add_unique_constraint("spatial_ref_sys_pkey", ["srid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JruYdlh72DSshfa0uhLfjw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
