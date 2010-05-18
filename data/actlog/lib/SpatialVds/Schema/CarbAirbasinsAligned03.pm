package SpatialVds::Schema::CarbAirbasinsAligned03;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("carb_airbasins_aligned_03");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('carb_airbasins_aligned_03_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "area",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "perimeter",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "abasa_",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "abasa_id",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "basin_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "ab",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 3,
  },
  "the_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "geom_4326",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("carb_airbasins_aligned_03_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RXTFyJqro5WWwAB2++4T0g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
