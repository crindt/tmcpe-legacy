package SpatialVds::Schema::OctamNodesGeom2230;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_nodes_geom_2230");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("octam_nodes_geom_2230_pkey", ["id"]);
__PACKAGE__->belongs_to("id", "SpatialVds::Schema::OctamNodes", { id => "id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NOqlvAoG90s2znJNVpwtbg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
