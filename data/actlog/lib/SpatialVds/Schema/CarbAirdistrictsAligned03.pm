package SpatialVds::Schema::CarbAirdistrictsAligned03;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("carb_airdistricts_aligned_03");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('carb_airdistricts_aligned_03_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "adisa_",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "adisa_id",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "dist_type",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 5,
  },
  "display",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "disti_area",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "dis",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 3,
  },
  "disn",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 35,
  },
  "the_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("carb_airdistricts_aligned_03_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dbcoKajbWTYJWf57cUrO3g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
