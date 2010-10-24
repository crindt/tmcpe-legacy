package SpatialVds::Schema::CarbCountiesAligned03;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("carb_counties_aligned_03");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('carb_counties_aligned_03_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "cacoa_",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "cacoa_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "coname",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "conum",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "display",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "symbol",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "islandname",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 35,
  },
  "baysplinte",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 35,
  },
  "cntyi_area",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "island_id",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "bay_id",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
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
__PACKAGE__->add_unique_constraint("carb_counties_aligned_03_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0kI3JQ1c6HhKgklESdqg9A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
