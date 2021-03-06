package SpatialVds::Schema::Pems5min;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("pems_5min");
__PACKAGE__->add_columns(
  "stamp",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "vdsid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "seg_len",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "samples_all",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "pct_obs_all",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_all",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_all",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_all",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "samples_1",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_1",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_1",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_1",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_1",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "samples_2",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_2",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_2",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_2",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_2",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "samples_3",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_3",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_3",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_3",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_3",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "samples_4",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_4",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_4",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_4",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_4",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "samples_5",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_5",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_5",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_5",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_5",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "samples_6",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_6",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_6",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_6",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_6",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "samples_7",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_7",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_7",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_7",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_7",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "samples_8",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "cnt_8",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "occ_8",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_8",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "obs_8",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "calendar_key",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "time_key",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("vdsid", "stamp");
__PACKAGE__->add_unique_constraint("pems_5min_pkey", ["vdsid", "stamp"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ImZ0I9vuYFN4XutjGzQMwQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
