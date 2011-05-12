package SpatialVds::Schema::DetectorCountsHr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::DetectorCountsHr

=cut

__PACKAGE__->table("detector_counts_hr");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 0

=head2 obs_day

  data_type: 'date'
  is_nullable: 0

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
  "obs_day",
  { data_type => "date", is_nullable => 0 },
  "truckcnt",
  { data_type => "real", is_nullable => 1 },
  "vehcnt",
  { data_type => "real", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("vds_id", "obs_day");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eZjtK51rfRg39lFNPv3zUA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
