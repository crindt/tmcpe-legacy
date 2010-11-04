package SpatialVds::Schema::Freeways;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Freeways

=cut

__PACKAGE__->table("freeways");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 freeway_osm_routes

Type: has_many

Related object: L<SpatialVds::Schema::FreewayOsmRoutes>

=cut

__PACKAGE__->has_many(
  "freeway_osm_routes",
  "SpatialVds::Schema::FreewayOsmRoutes",
  { "foreign.freeway_id" => "self.id" },
  {},
);

=head2 wim_freeways

Type: has_many

Related object: L<SpatialVds::Schema::WimFreeway>

=cut

__PACKAGE__->has_many(
  "wim_freeways",
  "SpatialVds::Schema::WimFreeway",
  { "foreign.freeway_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EmsxV+s6p6108i+1YUmjLw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
