package SpatialVds::Schema::WimData;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_data");
__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "lane",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 0,
    size => 2,
  },
  "ts",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "veh_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "veh_class",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 0,
    size => 2,
  },
  "gross_weight",
  { data_type => "real", default_value => undef, is_nullable => 0, size => 4 },
  "veh_len",
  { data_type => "real", default_value => undef, is_nullable => 0, size => 4 },
  "speed",
  { data_type => "real", default_value => undef, is_nullable => 0, size => 4 },
  "violation_code",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 0,
    size => 2,
  },
  "axle_1_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_1_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_2_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_2_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_1_2_spacing",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_3_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_3_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_2_3_spacing",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_4_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_4_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_3_4_spacing",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_5_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_5_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_4_5_spacing",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_6_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_6_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_5_6_spacing",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_7_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_7_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_6_7_spacing",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_8_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_8_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_7_8_spacing",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_9_rt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_9_lt_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "axle_8_9_spacing",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_no",
  {
    data_type => "integer",
    default_value => "nextval('wim_data_obs_no_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
);
__PACKAGE__->set_primary_key("site_no", "lane", "ts", "veh_no");
__PACKAGE__->add_unique_constraint("wim_data_pkey", ["site_no", "lane", "ts", "veh_no"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:46:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:22olwoZSAeFtxg+LUUuq5A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
