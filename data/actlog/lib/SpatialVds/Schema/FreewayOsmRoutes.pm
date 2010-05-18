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


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E6FZ5Nr5i5ds31xGEPqeHg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
