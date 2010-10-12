package SpatialVds::Schema::FinalMatchTbl;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("final_match_tbl");
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
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('final_match_tbl_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("match_vds_taz_uniq", ["vds_id", "taz_id"]);
__PACKAGE__->add_unique_constraint("final_match_tbl_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gbnjYEs8RMwSIzb+J9fcQg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
