package SpatialVds::Schema::MeanOnrTripDistance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::MeanOnrTripDistance

=cut

__PACKAGE__->table("mean_onr_trip_distance");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 geom_2230

  data_type: 'geometry'
  is_nullable: 1

=head2 count

  data_type: 'bigint'
  is_nullable: 1

=head2 avg_dist

  data_type: 'double precision'
  is_nullable: 1

=head2 avg_manhdist

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "geom_2230",
  { data_type => "geometry", is_nullable => 1 },
  "count",
  { data_type => "bigint", is_nullable => 1 },
  "avg_dist",
  { data_type => "double precision", is_nullable => 1 },
  "avg_manhdist",
  { data_type => "double precision", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Kie3lR8rm00mnJBhOHuugQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
