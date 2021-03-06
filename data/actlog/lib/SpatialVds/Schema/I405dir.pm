package SpatialVds::Schema::I405dir;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::I405dir

=cut

__PACKAGE__->table("i405dir");

=head1 ACCESSORS

=head2 ggid

  data_type: 'integer'
  is_nullable: 1

=head2 route_id

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 segment_id

  data_type: 'integer'
  is_nullable: 1

=head2 geom

  data_type: 'geometry'
  is_nullable: 1

=head2 ns_dir

  data_type: 'text'
  is_nullable: 1

=head2 ew_dir

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ggid",
  { data_type => "integer", is_nullable => 1 },
  "route_id",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "segment_id",
  { data_type => "integer", is_nullable => 1 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
  "ns_dir",
  { data_type => "text", is_nullable => 1 },
  "ew_dir",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S0BHYaDOPinwzwwU0WCvDA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
