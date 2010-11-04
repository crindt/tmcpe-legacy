package SpatialVds::Schema::OctamLinksGeom2230;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamLinksGeom2230

=cut

__PACKAGE__->table("octam_links_geom_2230");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 frnode

  data_type: 'integer'
  is_nullable: 1

=head2 tonode

  data_type: 'integer'
  is_nullable: 1

=head2 link_geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 1 },
  "frnode",
  { data_type => "integer", is_nullable => 1 },
  "tonode",
  { data_type => "integer", is_nullable => 1 },
  "link_geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YqRCec8WYKcd9wIg3t71JQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
