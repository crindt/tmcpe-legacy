package SpatialVds::Schema::AirbasinView;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("airbasin_view");
__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "area",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "perimiter",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "basin_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "the_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GEwUCvdxjg5HlX8SKoUvZA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
