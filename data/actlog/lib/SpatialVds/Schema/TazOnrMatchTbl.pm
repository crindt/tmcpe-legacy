package SpatialVds::Schema::TazOnrMatchTbl;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("taz_onr_match_tbl");
__PACKAGE__->add_columns(
  "taz_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "mindist",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "manhdist",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "linegeom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('taz_onr_match_tbl_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("taz_onr_match_tbl_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Dhn+n2Q33Rdz9Sdh2WAQYQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
