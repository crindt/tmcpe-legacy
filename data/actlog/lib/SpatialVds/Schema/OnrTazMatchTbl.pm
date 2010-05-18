package SpatialVds::Schema::OnrTazMatchTbl;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("onr_taz_match_tbl");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "taz_id",
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
    default_value => "nextval('onr_taz_match_tbl_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("onr_taz_match_tbl_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eQlJQqUzBs1uGxw1mhXMXA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
