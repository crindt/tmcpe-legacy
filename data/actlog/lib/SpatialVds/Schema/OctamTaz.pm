package SpatialVds::Schema::OctamTaz;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_taz");
__PACKAGE__->add_columns(
  "taz_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("taz_id");
__PACKAGE__->add_unique_constraint("octam_taz_pkey1", ["taz_id"]);
__PACKAGE__->has_many(
  "octam_sed_2000s",
  "SpatialVds::Schema::OctamSed2000",
  { "foreign.taz_id" => "self.taz_id" },
);
__PACKAGE__->has_many(
  "octam_taz_geoms",
  "SpatialVds::Schema::OctamTazGeom",
  { "foreign.taz_id" => "self.taz_id" },
);
__PACKAGE__->has_many(
  "vds_taz_intersections",
  "SpatialVds::Schema::VdsTazIntersections",
  { "foreign.taz_id" => "self.taz_id" },
);
__PACKAGE__->has_many(
  "vds_taz_intersections_alts",
  "SpatialVds::Schema::VdsTazIntersectionsAlt",
  { "foreign.taz_id" => "self.taz_id" },
);
__PACKAGE__->has_many(
  "vds_taz_intersections_simples",
  "SpatialVds::Schema::VdsTazIntersectionsSimple",
  { "foreign.taz_id" => "self.taz_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dtv7MADs5UiBqJH0I+VOYw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
