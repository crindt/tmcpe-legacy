package SpatialVds::Schema::OctamNodesGeom2875;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_nodes_geom_2875");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "geomfromewkt",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("octam_nodes_geom_2875_pkey", ["id"]);
__PACKAGE__->belongs_to("id", "SpatialVds::Schema::OctamNodes", { id => "id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:umZpvjOfCSALVUzm1Ci3bg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
