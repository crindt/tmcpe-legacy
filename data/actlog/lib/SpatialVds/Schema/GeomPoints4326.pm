package SpatialVds::Schema::GeomPoints4326;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::GeomPoints4326

=cut

__PACKAGE__->table("geom_points_4326");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");

=head1 RELATIONS

=head2 gid

Type: belongs_to

Related object: L<SpatialVds::Schema::GeomIds>

=cut

__PACKAGE__->belongs_to("gid", "SpatialVds::Schema::GeomIds", { gid => "gid" });

=head2 vds_points_4326s

Type: has_many

Related object: L<SpatialVds::Schema::VdsPoints4326>

=cut

__PACKAGE__->has_many(
  "vds_points_4326s",
  "SpatialVds::Schema::VdsPoints4326",
  { "foreign.gid" => "self.gid" },
  {},
);

=head2 wim_points_4326s

Type: has_many

Related object: L<SpatialVds::Schema::WimPoints4326>

=cut

__PACKAGE__->has_many(
  "wim_points_4326s",
  "SpatialVds::Schema::WimPoints4326",
  { "foreign.gid" => "self.gid" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1NSHK/wTaV9cJ27injaPrA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
