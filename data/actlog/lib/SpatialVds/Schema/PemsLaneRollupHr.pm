package SpatialVds::Schema::PemsLaneRollupHr;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("pems_lane_rollup_hr");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ts",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "fwydir",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "total_count",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "vehlanes_count",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "vehlanes_occ",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "trucklanes_count",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "trucklanes_occ",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "truckcnt",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vehcnt",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("vds_id", "ts");
__PACKAGE__->add_unique_constraint("pems_lane_rollup_hr_pkey", ["vds_id", "ts"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SS7lBRx3ruJt+TD5zVuyiQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
