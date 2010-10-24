package SpatialVds::Schema::MeanOnrTripDistance;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("mean_onr_trip_distance");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "geom_2230",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "count",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "avg_dist",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "avg_manhdist",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dHxkKX+XYv8KOS223CTdWw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
