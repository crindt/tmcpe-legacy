package SpatialVds::Schema::WimPoints4269;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_points_4269");
__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "wim_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("wim_id");
__PACKAGE__->add_unique_constraint("wim_points_4269_pkey", ["wim_id"]);
__PACKAGE__->belongs_to(
  "wim_id",
  "SpatialVds::Schema::WimStations",
  { site_no => "wim_id" },
);
__PACKAGE__->belongs_to("gid", "SpatialVds::Schema::GeomPoints4269", { gid => "gid" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1Bbe9Fy3h9iQMcK5JMCDTw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
