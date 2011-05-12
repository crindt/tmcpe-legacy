package SpatialVds::Schema::CarbAirdistrictsAligned03;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::CarbAirdistrictsAligned03

=cut

__PACKAGE__->table("carb_airdistricts_aligned_03");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'carb_airdistricts_aligned_03_gid_seq'

=head2 adisa_

  data_type: 'bigint'
  is_nullable: 1

=head2 adisa_id

  data_type: 'bigint'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 dist_type

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=head2 display

  data_type: 'smallint'
  is_nullable: 1

=head2 disti_area

  data_type: 'numeric'
  is_nullable: 1

=head2 dis

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 disn

  data_type: 'varchar'
  is_nullable: 1
  size: 35

=head2 the_geom

  data_type: 'geometry'
  is_nullable: 1

=head2 geom4326

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "carb_airdistricts_aligned_03_gid_seq",
  },
  "adisa_",
  { data_type => "bigint", is_nullable => 1 },
  "adisa_id",
  { data_type => "bigint", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "dist_type",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "display",
  { data_type => "smallint", is_nullable => 1 },
  "disti_area",
  { data_type => "numeric", is_nullable => 1 },
  "dis",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "disn",
  { data_type => "varchar", is_nullable => 1, size => 35 },
  "the_geom",
  { data_type => "geometry", is_nullable => 1 },
  "geom4326",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hlYprbX591LRCfnB/2jrxw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
