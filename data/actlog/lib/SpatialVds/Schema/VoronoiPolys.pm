package SpatialVds::Schema::VoronoiPolys;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VoronoiPolys

=cut

__PACKAGE__->table("voronoi_polys");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'voronoi_polys_gid_seq'

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 type_id

  data_type: 'char'
  is_nullable: 1
  size: 2

=head2 classifier

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

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
    sequence          => "voronoi_polys_gid_seq",
  },
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "type_id",
  { data_type => "char", is_nullable => 1, size => 2 },
  "classifier",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "geom_4326",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/r4N778UvR8Sb9zzy7Bijg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
