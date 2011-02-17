package SpatialVds::Schema::FreewayOsmRoutes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::FreewayOsmRoutes

=cut

__PACKAGE__->table("freeway_osm_routes");

=head1 ACCESSORS

=head2 freeway_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 osm_relation_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "freeway_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "osm_relation_id",
  { data_type => "integer", is_nullable => 0 },
);

=head1 RELATIONS

=head2 freeway_id

Type: belongs_to

Related object: L<SpatialVds::Schema::Freeways>

=cut

__PACKAGE__->belongs_to(
  "freeway_id",
  "SpatialVds::Schema::Freeways",
  { id => "freeway_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:J/xZgyTKWc+IBd3QE4MK7Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
