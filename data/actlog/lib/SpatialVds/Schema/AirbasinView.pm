package SpatialVds::Schema::AirbasinView;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::AirbasinView

=cut

__PACKAGE__->table("airbasin_view");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_nullable: 1

=head2 area

  data_type: 'numeric'
  is_nullable: 1

=head2 perimiter

  data_type: 'numeric'
  is_nullable: 1

=head2 basin_name

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 the_geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", is_nullable => 1 },
  "area",
  { data_type => "numeric", is_nullable => 1 },
  "perimiter",
  { data_type => "numeric", is_nullable => 1 },
  "basin_name",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "the_geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:utUKl9IdmFrwayyp2NrQ1g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
