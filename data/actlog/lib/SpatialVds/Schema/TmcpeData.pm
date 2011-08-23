package SpatialVds::Schema::TmcpeData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::TmcpeData

=cut

__PACKAGE__->table("tmcpe_data");

=head1 ACCESSORS

=head2 vdsid

  data_type: 'integer'
  is_nullable: 1

=head2 stamp

  data_type: 'timestamp'
  is_nullable: 1

=head2 o_vol

  data_type: 'smallint'
  is_nullable: 1

=head2 o_occ

  data_type: 'real'
  is_nullable: 1

=head2 o_spd

  data_type: 'real'
  is_nullable: 1

=head2 o_pct_obs

  data_type: 'smallint'
  is_nullable: 1

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
  "vdsid",
  { data_type => "integer", is_nullable => 1 },
  "stamp",
  { data_type => "timestamp", is_nullable => 1 },
  "o_vol",
  { data_type => "smallint", is_nullable => 1 },
  "o_occ",
  { data_type => "real", is_nullable => 1 },
  "o_spd",
  { data_type => "real", is_nullable => 1 },
  "o_pct_obs",
  { data_type => "smallint", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JIUwiFFELR+nVOUUS1C09Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
