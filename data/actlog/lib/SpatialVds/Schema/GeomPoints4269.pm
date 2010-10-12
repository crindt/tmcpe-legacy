package SpatialVds::Schema::GeomPoints4269;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("geom_points_4269");
__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("geom_points_4269_pkey", ["gid"]);
__PACKAGE__->belongs_to("gid", "SpatialVds::Schema::GeomIds", { gid => "gid" });
__PACKAGE__->has_many(
  "vds_points_4269s",
  "SpatialVds::Schema::VdsPoints4269",
  { "foreign.gid" => "self.gid" },
);
__PACKAGE__->has_many(
  "wim_points_4269s",
  "SpatialVds::Schema::WimPoints4269",
  { "foreign.gid" => "self.gid" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7hYpaVpgWXbWvehzPLxkeg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
