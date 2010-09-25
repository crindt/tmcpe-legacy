package SpatialVds::Schema::FreewayOsmRoutes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("freeway_osm_routes");
__PACKAGE__->add_columns(
  "freeway_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "osm_relation_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->belongs_to(
  "freeway_id",
  "SpatialVds::Schema::Freeways",
  { id => "freeway_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-24 21:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UA9NVGCwIe8d3c2bmwm1Mw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
