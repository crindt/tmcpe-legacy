package SpatialVds::Schema::TazShapes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("taz_shapes");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "tazs_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 23:55:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RDMrd6A3OUlE8G4wgTgl2Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
