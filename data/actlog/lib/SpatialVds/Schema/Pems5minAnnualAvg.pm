package SpatialVds::Schema::Pems5minAnnualAvg;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Pems5minAnnualAvg

=cut

__PACKAGE__->table("pems_5min_annual_avg");

=head1 ACCESSORS

=head2 stamp

  data_type: 'timestamp'
  is_nullable: 0

=head2 vdsid

  data_type: 'integer'
  is_nullable: 0

=head2 days_in_avg

  data_type: 'smallint'
  is_nullable: 1

=head2 avg_samples

  data_type: 'smallint'
  is_nullable: 1

=head2 a_pct_obs

  data_type: 'double precision'
  is_nullable: 1

=head2 a_vol

  data_type: 'double precision'
  is_nullable: 1

=head2 a_occ

  data_type: 'double precision'
  is_nullable: 1

=head2 a_spd

  data_type: 'double precision'
  is_nullable: 1

=head2 sd_vol

  data_type: 'double precision'
  is_nullable: 1

=head2 sd_occ

  data_type: 'double precision'
  is_nullable: 1

=head2 sd_spd

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "stamp",
  { data_type => "timestamp", is_nullable => 0 },
  "vdsid",
  { data_type => "integer", is_nullable => 0 },
  "days_in_avg",
  { data_type => "smallint", is_nullable => 1 },
  "avg_samples",
  { data_type => "smallint", is_nullable => 1 },
  "a_pct_obs",
  { data_type => "double precision", is_nullable => 1 },
  "a_vol",
  { data_type => "double precision", is_nullable => 1 },
  "a_occ",
  { data_type => "double precision", is_nullable => 1 },
  "a_spd",
  { data_type => "double precision", is_nullable => 1 },
  "sd_vol",
  { data_type => "double precision", is_nullable => 1 },
  "sd_occ",
  { data_type => "double precision", is_nullable => 1 },
  "sd_spd",
  { data_type => "double precision", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("stamp", "vdsid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:45nx0hnUPcWKvt08lCWGmw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
