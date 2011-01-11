package SpatialVds::Schema::WimStations;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimStations

=cut

__PACKAGE__->table("wim_stations");

=head1 ACCESSORS

=head2 site_no

  data_type: 'integer'
  is_nullable: 0

=head2 loc

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 lanes

  data_type: 'integer'
  is_nullable: 0

=head2 vendor

  data_type: 'varchar'
  is_nullable: 0
  size: 6

=head2 wim_type

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 cal_pm

  data_type: 'varchar'
  is_nullable: 0
  size: 12

=head2 abs_pm

  data_type: 'double precision'
  is_nullable: 1

=head2 latitude

  data_type: 'numeric'
  is_nullable: 1

=head2 longitude

  data_type: 'numeric'
  is_nullable: 1

=head2 last_modified

  data_type: 'date'
  default_value: ('now'::text)::date
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", is_nullable => 0 },
  "loc",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "lanes",
  { data_type => "integer", is_nullable => 0 },
  "vendor",
  { data_type => "varchar", is_nullable => 0, size => 6 },
  "wim_type",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "cal_pm",
  { data_type => "varchar", is_nullable => 0, size => 12 },
  "abs_pm",
  { data_type => "double precision", is_nullable => 1 },
  "latitude",
  { data_type => "numeric", is_nullable => 1 },
  "longitude",
  { data_type => "numeric", is_nullable => 1 },
  "last_modified",
  {
    data_type     => "date",
    default_value => \"('now'::text)::date",
    is_nullable   => 1,
  },
);
__PACKAGE__->set_primary_key("site_no");

=head1 RELATIONS

=head2 vds_wim_distances

Type: has_many

Related object: L<SpatialVds::Schema::VdsWimDistance>

=cut

__PACKAGE__->has_many(
  "vds_wim_distances",
  "SpatialVds::Schema::VdsWimDistance",
  { "foreign.wim_id" => "self.site_no" },
  {},
);

=head2 wim_counties

Type: has_many

Related object: L<SpatialVds::Schema::WimCounty>

=cut

__PACKAGE__->has_many(
  "wim_counties",
  "SpatialVds::Schema::WimCounty",
  { "foreign.wim_id" => "self.site_no" },
  {},
);

=head2 wim_districts

Type: has_many

Related object: L<SpatialVds::Schema::WimDistrict>

=cut

__PACKAGE__->has_many(
  "wim_districts",
  "SpatialVds::Schema::WimDistrict",
  { "foreign.wim_id" => "self.site_no" },
  {},
);

=head2 wim_freeways

Type: has_many

Related object: L<SpatialVds::Schema::WimFreeway>

=cut

__PACKAGE__->has_many(
  "wim_freeways",
  "SpatialVds::Schema::WimFreeway",
  { "foreign.wim_id" => "self.site_no" },
  {},
);

=head2 wim_lane_by_hour_reports

Type: has_many

Related object: L<SpatialVds::Schema::WimLaneByHourReport>

=cut

__PACKAGE__->has_many(
  "wim_lane_by_hour_reports",
  "SpatialVds::Schema::WimLaneByHourReport",
  { "foreign.site_no" => "self.site_no" },
  {},
);

=head2 wim_points_4269s

Type: has_many

Related object: L<SpatialVds::Schema::WimPoints4269>

=cut

__PACKAGE__->has_many(
  "wim_points_4269s",
  "SpatialVds::Schema::WimPoints4269",
  { "foreign.wim_id" => "self.site_no" },
  {},
);

=head2 wim_points_4326s

Type: has_many

Related object: L<SpatialVds::Schema::WimPoints4326>

=cut

__PACKAGE__->has_many(
  "wim_points_4326s",
  "SpatialVds::Schema::WimPoints4326",
  { "foreign.wim_id" => "self.site_no" },
  {},
);

=head2 wim_statuses

Type: has_many

Related object: L<SpatialVds::Schema::WimStatus>

=cut

__PACKAGE__->has_many(
  "wim_statuses",
  "SpatialVds::Schema::WimStatus",
  { "foreign.site_no" => "self.site_no" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jfFBC8otiemZpRJlA5tJYg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
