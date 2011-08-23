package SpatialVds::Schema::AnnualMainlineVolumes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::AnnualMainlineVolumes

=cut

__PACKAGE__->table("annual_mainline_volumes");

=head1 ACCESSORS

=head2 obs_year

  data_type: 'double precision'
  is_nullable: 1

=head2 annual_truck_vmt

  data_type: 'double precision'
  is_nullable: 1

=head2 annual_veh_vmt

  data_type: 'double precision'
  is_nullable: 1

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 vdstype

  data_type: 'varchar'
  is_nullable: 1
  size: 4

=head2 district

  data_type: 'integer'
  is_nullable: 1

=head2 facility

  data_type: 'text'
  is_nullable: 1

=head2 lanes

  data_type: 'integer'
  is_nullable: 1

=head2 cal_pm

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 abs_pm

  data_type: 'double precision'
  is_nullable: 1

=head2 length

  data_type: 'numeric'
  is_nullable: 1

=head2 latitude

  data_type: 'numeric'
  is_nullable: 1

=head2 longitude

  data_type: 'numeric'
  is_nullable: 1

=head2 gid

  data_type: 'integer'
  is_nullable: 1

=head2 geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "obs_year",
  { data_type => "double precision", is_nullable => 1 },
  "annual_truck_vmt",
  { data_type => "double precision", is_nullable => 1 },
  "annual_veh_vmt",
  { data_type => "double precision", is_nullable => 1 },
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "vdstype",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "district",
  { data_type => "integer", is_nullable => 1 },
  "facility",
  { data_type => "text", is_nullable => 1 },
  "lanes",
  { data_type => "integer", is_nullable => 1 },
  "cal_pm",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "abs_pm",
  { data_type => "double precision", is_nullable => 1 },
  "length",
  { data_type => "numeric", is_nullable => 1 },
  "latitude",
  { data_type => "numeric", is_nullable => 1 },
  "longitude",
  { data_type => "numeric", is_nullable => 1 },
  "gid",
  { data_type => "integer", is_nullable => 1 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+Oxtqyhs5ErELJiQGDZATQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
