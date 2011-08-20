package SpatialVds::Schema::WimLaneByHourReport;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimLaneByHourReport

=cut

__PACKAGE__->table("wim_lane_by_hour_report");

=head1 ACCESSORS

=head2 site_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 direction

  data_type: 'varchar'
  is_nullable: 0
  size: 1

=head2 lane_no

  data_type: 'integer'
  is_nullable: 0

=head2 wim_lane_no

  data_type: 'integer'
  is_nullable: 0

=head2 ts_hour

  data_type: 'timestamp'
  is_nullable: 0

=head2 volume

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "direction",
  { data_type => "varchar", is_nullable => 0, size => 1 },
  "lane_no",
  { data_type => "integer", is_nullable => 0 },
  "wim_lane_no",
  { data_type => "integer", is_nullable => 0 },
  "ts_hour",
  { data_type => "timestamp", is_nullable => 0 },
  "volume",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("site_no", "wim_lane_no", "ts_hour");

=head1 RELATIONS

=head2 site_no

Type: belongs_to

Related object: L<SpatialVds::Schema::WimStations>

=cut

__PACKAGE__->belongs_to(
  "site_no",
  "SpatialVds::Schema::WimStations",
  { site_no => "site_no" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0wv5INJQwFNHiokhR3kniA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
