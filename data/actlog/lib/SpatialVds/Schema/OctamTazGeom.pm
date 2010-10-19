package SpatialVds::Schema::OctamTazGeom;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_taz_geom");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('octam_taz_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "taz_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "area",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "id1",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "area1",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "perimeter",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "octam3_reg",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "octam3_re1",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "taz",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "caa_",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "rsa_",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "tier1_",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "the_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "geom_2771",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("taz_id_unique", ["taz_id"]);
__PACKAGE__->add_unique_constraint("octam_taz_pkey", ["gid"]);
__PACKAGE__->belongs_to(
  "taz_id",
  "SpatialVds::Schema::OctamTaz",
  { taz_id => "taz_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:46:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zLHv9fylNAcGUHOLGVHTyQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
