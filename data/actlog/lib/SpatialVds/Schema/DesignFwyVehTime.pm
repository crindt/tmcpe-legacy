package SpatialVds::Schema::DesignFwyVehTime;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("design_fwy_veh_time");
__PACKAGE__->add_columns(
  "obs_no",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "site_no",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "district_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "fwydir",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "dow",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "timeofday",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "fouraxle",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "heavytruck",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:46:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qyDZUPUH5FL9cdc0MJd0XA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
