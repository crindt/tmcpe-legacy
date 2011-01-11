package SpatialVds::Schema::JoinedVdsGeom;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::JoinedVdsGeom

=cut

__PACKAGE__->table("joined_vds_geom");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'joined_vds_geom_gid_seq'

=head2 freeway_id

  data_type: 'integer'
  is_nullable: 1

=head2 district_id

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 cnt

  data_type: 'smallint'
  is_nullable: 1

=head2 geom

  data_type: 'geometry'
  is_nullable: 1

=head2 shape_geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "joined_vds_geom_gid_seq",
  },
  "freeway_id",
  { data_type => "integer", is_nullable => 1 },
  "district_id",
  { data_type => "integer", is_nullable => 1 },
  "name",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "cnt",
  { data_type => "smallint", is_nullable => 1 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
  "shape_geom",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MT1zmUk9qAVOp+bHs86qVA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
