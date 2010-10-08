package SpatialVds::Schema::VoronoiPolys;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("voronoi_polys");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('voronoi_polys_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "type_id",
  {
    data_type => "character",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "classifier",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "geom_4326",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("voronoi_polys_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YgjAlOOz3PVMu1CIsQ/u4w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
