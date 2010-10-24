package SpatialVds::Schema::OctamLinksGeom2230;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_links_geom_2230");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "frnode",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "tonode",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "link_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dW8b3QP8JB1d9AK4Hl58wA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
