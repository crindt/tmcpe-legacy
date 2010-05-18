package SpatialVds::Schema::WimLaneByHourReport;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_lane_by_hour_report");
__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "direction",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 1,
  },
  "lane_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "wim_lane_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ts_hour",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "volume",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("site_no", "wim_lane_no", "ts_hour");
__PACKAGE__->add_unique_constraint(
  "wim_lane_by_hour_report_pkey",
  ["site_no", "wim_lane_no", "ts_hour"],
);
__PACKAGE__->belongs_to(
  "site_no",
  "SpatialVds::Schema::WimStations",
  { site_no => "site_no" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vBWzmCiGr9Ee66SXv3MIrQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
