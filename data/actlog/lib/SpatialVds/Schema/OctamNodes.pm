package SpatialVds::Schema::OctamNodes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamNodes

=cut

__PACKAGE__->table("octam_nodes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 x

  data_type: 'integer'
  is_nullable: 1

=head2 y

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "x",
  { data_type => "integer", is_nullable => 1 },
  "y",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 octam_links_tonodes

Type: has_many

Related object: L<SpatialVds::Schema::OctamLinks>

=cut

__PACKAGE__->has_many(
  "octam_links_tonodes",
  "SpatialVds::Schema::OctamLinks",
  { "foreign.tonode" => "self.id" },
  {},
);

=head2 octam_links_frnodes

Type: has_many

Related object: L<SpatialVds::Schema::OctamLinks>

=cut

__PACKAGE__->has_many(
  "octam_links_frnodes",
  "SpatialVds::Schema::OctamLinks",
  { "foreign.frnode" => "self.id" },
  {},
);

=head2 octam_nodes_geom_2230s

Type: has_many

Related object: L<SpatialVds::Schema::OctamNodesGeom2230>

=cut

__PACKAGE__->has_many(
  "octam_nodes_geom_2230s",
  "SpatialVds::Schema::OctamNodesGeom2230",
  { "foreign.id" => "self.id" },
  {},
);

=head2 octam_nodes_geom_2875s

Type: has_many

Related object: L<SpatialVds::Schema::OctamNodesGeom2875>

=cut

__PACKAGE__->has_many(
  "octam_nodes_geom_2875s",
  "SpatialVds::Schema::OctamNodesGeom2875",
  { "foreign.id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:U+1hopif/pUIUd9ScncTrA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
