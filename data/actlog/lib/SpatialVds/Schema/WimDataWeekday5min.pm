package SpatialVds::Schema::WimDataWeekday5min;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimDataWeekday5min

=cut

__PACKAGE__->table("wim_data_weekday5min");

=head1 ACCESSORS

=head2 site_no

  data_type: 'integer'
  is_nullable: 0

=head2 direction

  data_type: 'varchar'
  is_nullable: 0
  size: 1

=head2 facility

  data_type: 'integer'
  is_nullable: 0

=head2 data_year

  data_type: 'integer'
  is_nullable: 0

=head2 weekday

  data_type: 'varchar'
  is_nullable: 0
  size: 3

=head2 five_minute

  data_type: 'time'
  is_nullable: 0
  size: 6

=head2 observations

  data_type: 'integer'
  is_nullable: 0

=head2 vh_count

  data_type: 'integer'
  is_nullable: 1

=head2 vh_fraction

  data_type: 'real'
  is_nullable: 1

=head2 mean_interarrivals

  data_type: 'real'
  is_nullable: 1

=head2 mean_gross_weight

  data_type: 'real'
  is_nullable: 1

=head2 mean_veh_len

  data_type: 'real'
  is_nullable: 1

=head2 mean_speed

  data_type: 'real'
  is_nullable: 1

=head2 mean_total_axle_spacings

  data_type: 'real'
  is_nullable: 1

=head2 var_gross_weight

  data_type: 'real'
  is_nullable: 1

=head2 var_veh_len

  data_type: 'real'
  is_nullable: 1

=head2 var_speed

  data_type: 'real'
  is_nullable: 1

=head2 var_total_axle_spacings

  data_type: 'real'
  is_nullable: 1

=head2 vh_mean_interarrivals

  data_type: 'real'
  is_nullable: 1

=head2 vh_mean_gross_weight

  data_type: 'real'
  is_nullable: 1

=head2 vh_mean_veh_len

  data_type: 'real'
  is_nullable: 1

=head2 vh_mean_speed

  data_type: 'real'
  is_nullable: 1

=head2 vh_mean_total_axle_spacings

  data_type: 'real'
  is_nullable: 1

=head2 vh_var_gross_weight

  data_type: 'real'
  is_nullable: 1

=head2 vh_var_veh_len

  data_type: 'real'
  is_nullable: 1

=head2 vh_var_speed

  data_type: 'real'
  is_nullable: 1

=head2 vh_var_total_axle_spacings

  data_type: 'real'
  is_nullable: 1

=head2 nvh_mean_interarrivals

  data_type: 'real'
  is_nullable: 1

=head2 nvh_mean_gross_weight

  data_type: 'real'
  is_nullable: 1

=head2 nvh_mean_veh_len

  data_type: 'real'
  is_nullable: 1

=head2 nvh_mean_speed

  data_type: 'real'
  is_nullable: 1

=head2 nvh_mean_total_axle_spacings

  data_type: 'real'
  is_nullable: 1

=head2 nvh_var_gross_weight

  data_type: 'real'
  is_nullable: 1

=head2 nvh_var_veh_len

  data_type: 'real'
  is_nullable: 1

=head2 nvh_var_speed

  data_type: 'real'
  is_nullable: 1

=head2 nvh_var_total_axle_spacings

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", is_nullable => 0 },
  "direction",
  { data_type => "varchar", is_nullable => 0, size => 1 },
  "facility",
  { data_type => "integer", is_nullable => 0 },
  "data_year",
  { data_type => "integer", is_nullable => 0 },
  "weekday",
  { data_type => "varchar", is_nullable => 0, size => 3 },
  "five_minute",
  { data_type => "time", is_nullable => 0, size => 6 },
  "observations",
  { data_type => "integer", is_nullable => 0 },
  "vh_count",
  { data_type => "integer", is_nullable => 1 },
  "vh_fraction",
  { data_type => "real", is_nullable => 1 },
  "mean_interarrivals",
  { data_type => "real", is_nullable => 1 },
  "mean_gross_weight",
  { data_type => "real", is_nullable => 1 },
  "mean_veh_len",
  { data_type => "real", is_nullable => 1 },
  "mean_speed",
  { data_type => "real", is_nullable => 1 },
  "mean_total_axle_spacings",
  { data_type => "real", is_nullable => 1 },
  "var_gross_weight",
  { data_type => "real", is_nullable => 1 },
  "var_veh_len",
  { data_type => "real", is_nullable => 1 },
  "var_speed",
  { data_type => "real", is_nullable => 1 },
  "var_total_axle_spacings",
  { data_type => "real", is_nullable => 1 },
  "vh_mean_interarrivals",
  { data_type => "real", is_nullable => 1 },
  "vh_mean_gross_weight",
  { data_type => "real", is_nullable => 1 },
  "vh_mean_veh_len",
  { data_type => "real", is_nullable => 1 },
  "vh_mean_speed",
  { data_type => "real", is_nullable => 1 },
  "vh_mean_total_axle_spacings",
  { data_type => "real", is_nullable => 1 },
  "vh_var_gross_weight",
  { data_type => "real", is_nullable => 1 },
  "vh_var_veh_len",
  { data_type => "real", is_nullable => 1 },
  "vh_var_speed",
  { data_type => "real", is_nullable => 1 },
  "vh_var_total_axle_spacings",
  { data_type => "real", is_nullable => 1 },
  "nvh_mean_interarrivals",
  { data_type => "real", is_nullable => 1 },
  "nvh_mean_gross_weight",
  { data_type => "real", is_nullable => 1 },
  "nvh_mean_veh_len",
  { data_type => "real", is_nullable => 1 },
  "nvh_mean_speed",
  { data_type => "real", is_nullable => 1 },
  "nvh_mean_total_axle_spacings",
  { data_type => "real", is_nullable => 1 },
  "nvh_var_gross_weight",
  { data_type => "real", is_nullable => 1 },
  "nvh_var_veh_len",
  { data_type => "real", is_nullable => 1 },
  "nvh_var_speed",
  { data_type => "real", is_nullable => 1 },
  "nvh_var_total_axle_spacings",
  { data_type => "real", is_nullable => 1 },
);
__PACKAGE__->set_primary_key(
  "weekday",
  "five_minute",
  "site_no",
  "direction",
  "facility",
  "data_year",
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rpEBUG3MDAkN91pUY/7UYg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
