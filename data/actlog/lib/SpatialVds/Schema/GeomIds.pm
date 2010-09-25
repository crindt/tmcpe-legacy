package SpatialVds::Schema::GeomIds;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("geom_ids");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('geom_ids_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "dummy",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("geom_ids_pkey", ["gid"]);
__PACKAGE__->has_many(
  "geom_points_4269s",
  "SpatialVds::Schema::GeomPoints4269",
  { "foreign.gid" => "self.gid" },
);
__PACKAGE__->has_many(
  "geom_points_4326s",
  "SpatialVds::Schema::GeomPoints4326",
  { "foreign.gid" => "self.gid" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-24 21:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:44am0XLpaflWjMtQr7kgbQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
