package SpatialVds::Schema::OctamTazGeom2230;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamTazGeom2230

=cut

__PACKAGE__->table("octam_taz_geom_2230");

=head1 ACCESSORS

=head2 taz_id

  data_type: 'integer'
  is_nullable: 0

=head2 geom_2230

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "taz_id",
  { data_type => "integer", is_nullable => 0 },
  "geom_2230",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("taz_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l1IlAdS5vN0lNZuA9FKUrw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
