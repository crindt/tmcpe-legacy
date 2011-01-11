package SpatialVds::Schema::OctamTaz;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamTaz

=cut

__PACKAGE__->table("octam_taz");

=head1 ACCESSORS

=head2 taz_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("taz_id", { data_type => "integer", is_nullable => 0 });
__PACKAGE__->set_primary_key("taz_id");

=head1 RELATIONS

=head2 octam_sed_2000s

Type: has_many

Related object: L<SpatialVds::Schema::OctamSed2000>

=cut

__PACKAGE__->has_many(
  "octam_sed_2000s",
  "SpatialVds::Schema::OctamSed2000",
  { "foreign.taz_id" => "self.taz_id" },
  {},
);

=head2 octam_taz_geoms

Type: has_many

Related object: L<SpatialVds::Schema::OctamTazGeom>

=cut

__PACKAGE__->has_many(
  "octam_taz_geoms",
  "SpatialVds::Schema::OctamTazGeom",
  { "foreign.taz_id" => "self.taz_id" },
  {},
);

=head2 vds_taz_intersections

Type: has_many

Related object: L<SpatialVds::Schema::VdsTazIntersections>

=cut

__PACKAGE__->has_many(
  "vds_taz_intersections",
  "SpatialVds::Schema::VdsTazIntersections",
  { "foreign.taz_id" => "self.taz_id" },
  {},
);

=head2 vds_taz_intersections_alts

Type: has_many

Related object: L<SpatialVds::Schema::VdsTazIntersectionsAlt>

=cut

__PACKAGE__->has_many(
  "vds_taz_intersections_alts",
  "SpatialVds::Schema::VdsTazIntersectionsAlt",
  { "foreign.taz_id" => "self.taz_id" },
  {},
);

=head2 vds_taz_intersections_simples

Type: has_many

Related object: L<SpatialVds::Schema::VdsTazIntersectionsSimple>

=cut

__PACKAGE__->has_many(
  "vds_taz_intersections_simples",
  "SpatialVds::Schema::VdsTazIntersectionsSimple",
  { "foreign.taz_id" => "self.taz_id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RHNvIovYyaWHrq0gPkZAbw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
