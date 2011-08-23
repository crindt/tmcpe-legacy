package SpatialVds::Schema::WimStationsGeoview;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimStationsGeoview

=cut

__PACKAGE__->table("wim_stations_geoview");

=head1 ACCESSORS

=head2 site_no

  data_type: 'integer'
  is_nullable: 1

=head2 loc

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 lanes

  data_type: 'integer'
  is_nullable: 1

=head2 vendor

  data_type: 'varchar'
  is_nullable: 1
  size: 6

=head2 wim_type

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 cal_pm

  data_type: 'varchar'
  is_nullable: 1
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
  is_nullable: 1

=head2 gid

  data_type: 'integer'
  is_nullable: 1

=head2 geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", is_nullable => 1 },
  "loc",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "lanes",
  { data_type => "integer", is_nullable => 1 },
  "vendor",
  { data_type => "varchar", is_nullable => 1, size => 6 },
  "wim_type",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "cal_pm",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "abs_pm",
  { data_type => "double precision", is_nullable => 1 },
  "latitude",
  { data_type => "numeric", is_nullable => 1 },
  "longitude",
  { data_type => "numeric", is_nullable => 1 },
  "last_modified",
  { data_type => "date", is_nullable => 1 },
  "gid",
  { data_type => "integer", is_nullable => 1 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Px2OgC3tXKSYNt8GUJVs1w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
