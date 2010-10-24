package SpatialVds::Schema::OctamNodes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_nodes");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "x",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "y",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("octamnodes_pkey", ["id"]);
__PACKAGE__->has_many(
  "octam_links_tonodes",
  "SpatialVds::Schema::OctamLinks",
  { "foreign.tonode" => "self.id" },
);
__PACKAGE__->has_many(
  "octam_links_frnodes",
  "SpatialVds::Schema::OctamLinks",
  { "foreign.frnode" => "self.id" },
);
__PACKAGE__->has_many(
  "octam_nodes_geom_2230s",
  "SpatialVds::Schema::OctamNodesGeom2230",
  { "foreign.id" => "self.id" },
);
__PACKAGE__->has_many(
  "octam_nodes_geom_2875s",
  "SpatialVds::Schema::OctamNodesGeom2875",
  { "foreign.id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/dbGrDkqNZA7QjxITaESkg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
