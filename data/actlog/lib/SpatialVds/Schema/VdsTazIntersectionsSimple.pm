package SpatialVds::Schema::VdsTazIntersectionsSimple;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_taz_intersections_simple");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('vds_taz_intersections_simple_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "taz_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "fraction",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "geom_4326",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "map_line_4326",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("vds_taz_intersections_simple_pkey", ["gid"]);
__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::Vds", { id => "vds_id" });
__PACKAGE__->belongs_to(
  "taz_id",
  "SpatialVds::Schema::OctamTaz",
  { taz_id => "taz_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:reVgZ0Scpi41bHF/7w4z+Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
