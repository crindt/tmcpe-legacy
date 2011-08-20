package SpatialVds::Schema::PemsLaneRollupHr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::PemsLaneRollupHr

=cut

__PACKAGE__->table("pems_lane_rollup_hr");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 0

=head2 ts

  data_type: 'timestamp'
  is_nullable: 0

=head2 fwydir

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 total_count

  data_type: 'integer'
  is_nullable: 1

=head2 vehlanes_count

  data_type: 'integer'
  is_nullable: 1

=head2 vehlanes_occ

  data_type: 'numeric'
  is_nullable: 1

=head2 trucklanes_count

  data_type: 'integer'
  is_nullable: 1

=head2 trucklanes_occ

  data_type: 'numeric'
  is_nullable: 1

=head2 truckcnt

  data_type: 'real'
  is_nullable: 1

=head2 vehcnt

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 0 },
  "ts",
  { data_type => "timestamp", is_nullable => 0 },
  "fwydir",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "total_count",
  { data_type => "integer", is_nullable => 1 },
  "vehlanes_count",
  { data_type => "integer", is_nullable => 1 },
  "vehlanes_occ",
  { data_type => "numeric", is_nullable => 1 },
  "trucklanes_count",
  { data_type => "integer", is_nullable => 1 },
  "trucklanes_occ",
  { data_type => "numeric", is_nullable => 1 },
  "truckcnt",
  { data_type => "real", is_nullable => 1 },
  "vehcnt",
  { data_type => "real", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("vds_id", "ts");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YmRvWBpwaNkSBjskWpBVFA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
