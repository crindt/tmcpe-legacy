package SpatialVds::Schema::TazShapes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::TazShapes

=cut

__PACKAGE__->table("taz_shapes");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 tazs_geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "tazs_geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LjrMxXjPh9FhXgQYueWfjA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
