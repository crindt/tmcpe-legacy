package SpatialVds::Schema::Freeways;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("freeways");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("freeways_pkey", ["id"]);
__PACKAGE__->has_many(
  "freeway_osm_routes",
  "SpatialVds::Schema::FreewayOsmRoutes",
  { "foreign.freeway_id" => "self.id" },
);
__PACKAGE__->has_many(
  "wim_freeways",
  "SpatialVds::Schema::WimFreeway",
  { "foreign.freeway_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 23:55:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vz7IqvyB3Cvtx5UK9RZ5wA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
