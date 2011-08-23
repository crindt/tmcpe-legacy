package SpatialVds::Schema::Vds2007dataGeoview;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Vds2007dataGeoview

=cut

__PACKAGE__->table("vds_2007data_geoview");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 type_id

  data_type: 'varchar'
  is_nullable: 1
  size: 4

=head2 district_id

  data_type: 'integer'
  is_nullable: 1

=head2 freeway_dir

  data_type: 'varchar'
  is_nullable: 1
  size: 2

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
  "id",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "type_id",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "district_id",
  { data_type => "integer", is_nullable => 1 },
  "freeway_dir",
  { data_type => "varchar", is_nullable => 1, size => 2 },
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
  "last_modified",
  { data_type => "date", is_nullable => 1 },
  "gid",
  { data_type => "integer", is_nullable => 1 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kgg+Pe3T9SthVERjxq7yqg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
