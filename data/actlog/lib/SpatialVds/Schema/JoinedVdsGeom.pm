package SpatialVds::Schema::JoinedVdsGeom;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("joined_vds_geom");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('joined_vds_geom_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "freeway_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "district_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "cnt",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "shape_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("joined_vds_geom_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i8d00OhtV3yDDNIzUg0kyA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
