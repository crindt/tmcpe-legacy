package SpatialVds::Schema::TmcpeDataCreate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::TmcpeDataCreate

=cut

__PACKAGE__->table("tmcpe_data_create");

=head1 ACCESSORS

=head2 stamp

  data_type: 'timestamp'
  is_nullable: 1

=head2 vdsid

  data_type: 'integer'
  is_nullable: 1

=head2 days_in_avg

  data_type: 'bigint'
  is_nullable: 1

=head2 avg_samples

  data_type: 'bigint'
  is_nullable: 1

=head2 a_pct_obs

  data_type: 'numeric'
  is_nullable: 1

=head2 a_vol

  data_type: 'numeric'
  is_nullable: 1

=head2 a_occ

  data_type: 'double precision'
  is_nullable: 1

=head2 a_spd

  data_type: 'double precision'
  is_nullable: 1

=head2 sd_vol

  data_type: 'numeric'
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
  { data_type => "timestamp", is_nullable => 1 },
  "vdsid",
  { data_type => "integer", is_nullable => 1 },
  "days_in_avg",
  { data_type => "bigint", is_nullable => 1 },
  "avg_samples",
  { data_type => "bigint", is_nullable => 1 },
  "a_pct_obs",
  { data_type => "numeric", is_nullable => 1 },
  "a_vol",
  { data_type => "numeric", is_nullable => 1 },
  "a_occ",
  { data_type => "double precision", is_nullable => 1 },
  "a_spd",
  { data_type => "double precision", is_nullable => 1 },
  "sd_vol",
  { data_type => "numeric", is_nullable => 1 },
  "sd_occ",
  { data_type => "double precision", is_nullable => 1 },
  "sd_spd",
  { data_type => "double precision", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8vd0Cp8OsMoK4xy0G1Tg+A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
