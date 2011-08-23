package SpatialVds::Schema::GeomIds;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::GeomIds

=cut

__PACKAGE__->table("geom_ids");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'geom_ids_gid_seq'

=head2 dummy

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "geom_ids_gid_seq",
  },
  "dummy",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");

=head1 RELATIONS

=head2 geom_points_4269s

Type: has_many

Related object: L<SpatialVds::Schema::GeomPoints4269>

=cut

__PACKAGE__->has_many(
  "geom_points_4269s",
  "SpatialVds::Schema::GeomPoints4269",
  { "foreign.gid" => "self.gid" },
  {},
);

=head2 geom_points_4326s

Type: has_many

Related object: L<SpatialVds::Schema::GeomPoints4326>

=cut

__PACKAGE__->has_many(
  "geom_points_4326s",
  "SpatialVds::Schema::GeomPoints4326",
  { "foreign.gid" => "self.gid" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QzF9ZuIhCMUkStobWpWmmw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
