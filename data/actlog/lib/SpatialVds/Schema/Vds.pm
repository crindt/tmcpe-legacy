package SpatialVds::Schema::Vds;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('vds_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "freeway_dir",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 2,
  },
  "lanes",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "cal_pm",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 12,
  },
  "abs_pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "latitude",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "longitude",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "last_modified",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "length",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("vds_pkey", ["id"]);
__PACKAGE__->has_many(
  "accident_risk_results",
  "SpatialVds::Schema::AccidentRiskResults",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_haspems5mins",
  "SpatialVds::Schema::VdsHaspems5min",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_stats",
  "SpatialVds::Schema::VdsStats",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_summarystats",
  "SpatialVds::Schema::VdsSummarystats",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_taz_intersections",
  "SpatialVds::Schema::VdsTazIntersections",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_taz_intersections_alts",
  "SpatialVds::Schema::VdsTazIntersectionsAlt",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_taz_intersections_simples",
  "SpatialVds::Schema::VdsTazIntersectionsSimple",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_wim_distances",
  "SpatialVds::Schema::VdsWimDistance",
  { "foreign.vds_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l2aSscT3PrK91JbUn1k5tQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
