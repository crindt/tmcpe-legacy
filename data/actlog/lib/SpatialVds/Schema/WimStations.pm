package SpatialVds::Schema::WimStations;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_stations");
__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "loc",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "lanes",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "vendor",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 6,
  },
  "wim_type",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
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
    is_nullable => 1,
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
  {
    data_type => "date",
    default_value => "('now'::text)::date",
    is_nullable => 1,
    size => 4,
  },
);
__PACKAGE__->set_primary_key("site_no");
__PACKAGE__->add_unique_constraint("wim_stations_pkey", ["site_no"]);
__PACKAGE__->has_many(
  "vds_wim_distances",
  "SpatialVds::Schema::VdsWimDistance",
  { "foreign.wim_id" => "self.site_no" },
);
__PACKAGE__->has_many(
  "wim_counties",
  "SpatialVds::Schema::WimCounty",
  { "foreign.wim_id" => "self.site_no" },
);
__PACKAGE__->has_many(
  "wim_districts",
  "SpatialVds::Schema::WimDistrict",
  { "foreign.wim_id" => "self.site_no" },
);
__PACKAGE__->has_many(
  "wim_freeways",
  "SpatialVds::Schema::WimFreeway",
  { "foreign.wim_id" => "self.site_no" },
);
__PACKAGE__->has_many(
  "wim_lane_by_hour_reports",
  "SpatialVds::Schema::WimLaneByHourReport",
  { "foreign.site_no" => "self.site_no" },
);
__PACKAGE__->has_many(
  "wim_points_4269s",
  "SpatialVds::Schema::WimPoints4269",
  { "foreign.wim_id" => "self.site_no" },
);
__PACKAGE__->has_many(
  "wim_points_4326s",
  "SpatialVds::Schema::WimPoints4326",
  { "foreign.wim_id" => "self.site_no" },
);
__PACKAGE__->has_many(
  "wim_statuses",
  "SpatialVds::Schema::WimStatus",
  { "foreign.site_no" => "self.site_no" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-27 17:06:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1/oIb2Uh3AcG+he/1LiG7Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
