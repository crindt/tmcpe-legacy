package SpatialVds::Schema::OctamNodesGeom2230;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamNodesGeom2230

=cut

__PACKAGE__->table("octam_nodes_geom_2230");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<SpatialVds::Schema::OctamNodes>

=cut

__PACKAGE__->belongs_to("id", "SpatialVds::Schema::OctamNodes", { id => "id" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6sGDj2hlaULtChG95kpwmw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
