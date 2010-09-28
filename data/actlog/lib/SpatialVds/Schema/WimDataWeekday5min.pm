package SpatialVds::Schema::WimDataWeekday5min;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_data_weekday5min");
__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "direction",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 1,
  },
  "facility",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "data_year",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "weekday",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 3,
  },
  "five_minute",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "observations",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "vh_count",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "vh_fraction",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "mean_interarrivals",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "mean_gross_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "mean_veh_len",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "mean_speed",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "mean_total_axle_spacings",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "var_gross_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "var_veh_len",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "var_speed",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "var_total_axle_spacings",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_mean_interarrivals",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_mean_gross_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_mean_veh_len",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_mean_speed",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_mean_total_axle_spacings",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_var_gross_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_var_veh_len",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_var_speed",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vh_var_total_axle_spacings",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_mean_interarrivals",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_mean_gross_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_mean_veh_len",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_mean_speed",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_mean_total_axle_spacings",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_var_gross_weight",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_var_veh_len",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_var_speed",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "nvh_var_total_axle_spacings",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key(
  "weekday",
  "five_minute",
  "site_no",
  "direction",
  "facility",
  "data_year",
);
__PACKAGE__->add_unique_constraint(
  "wim_data_weekday5min_pkey",
  [
    "weekday",
    "five_minute",
    "site_no",
    "direction",
    "facility",
    "data_year",
  ],
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-27 17:06:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:s7WuBl3EYBsY+XU3jSoI6g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
