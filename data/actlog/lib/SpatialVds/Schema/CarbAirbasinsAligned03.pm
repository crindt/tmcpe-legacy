package SpatialVds::Schema::CarbAirbasinsAligned03;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::CarbAirbasinsAligned03

=cut

__PACKAGE__->table("carb_airbasins_aligned_03");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'carb_airbasins_aligned_03_gid_seq'

=head2 area

  data_type: 'numeric'
  is_nullable: 1

=head2 perimeter

  data_type: 'numeric'
  is_nullable: 1

=head2 abasa_

  data_type: 'bigint'
  is_nullable: 1

=head2 abasa_id

  data_type: 'bigint'
  is_nullable: 1

=head2 basin_name

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 ab

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 the_geom

  data_type: 'geometry'
  is_nullable: 1

=head2 geom_4326

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "carb_airbasins_aligned_03_gid_seq",
  },
  "area",
  { data_type => "numeric", is_nullable => 1 },
  "perimeter",
  { data_type => "numeric", is_nullable => 1 },
  "abasa_",
  { data_type => "bigint", is_nullable => 1 },
  "abasa_id",
  { data_type => "bigint", is_nullable => 1 },
  "basin_name",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "ab",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "the_geom",
  { data_type => "geometry", is_nullable => 1 },
  "geom_4326",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XLIr173u1aG7OcDa0kvTeQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
