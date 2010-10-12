package SpatialVds::Schema::WimLengthWeekDayFacility;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_length_week_day_facility");
__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "fwydir",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "datayear",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "weekday",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "timeofday",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "totalvehicles",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "totalfouraxle",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "totalheavytruck",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "totalheavyheavy",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "totalother",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "fouraxlelength",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "heavytrucklegth",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "heavyheavylength",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "otherlength",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("weekday", "timeofday", "site_no", "fwydir", "datayear");
__PACKAGE__->add_unique_constraint(
  "wim_length_week_day_facility_pkey",
  ["weekday", "timeofday", "site_no", "fwydir", "datayear"],
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kxdUhd0GdqwuptpTQ6Ec7w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
