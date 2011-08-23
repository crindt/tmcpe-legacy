package SpatialVds::Schema::Vds;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Vds

=cut

__PACKAGE__->table("vds");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'vds_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 freeway_dir

  data_type: 'varchar'
  is_nullable: 0
  size: 2

=head2 lanes

  data_type: 'integer'
  is_nullable: 0

=head2 cal_pm

  data_type: 'varchar'
  is_nullable: 0
  size: 12

=head2 abs_pm

  data_type: 'double precision'
  is_nullable: 0

=head2 latitude

  data_type: 'numeric'
  is_nullable: 1

=head2 longitude

  data_type: 'numeric'
  is_nullable: 1

=head2 last_modified

  data_type: 'date'
  is_nullable: 1

=head2 length

  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "vds_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "freeway_dir",
  { data_type => "varchar", is_nullable => 0, size => 2 },
  "lanes",
  { data_type => "integer", is_nullable => 0 },
  "cal_pm",
  { data_type => "varchar", is_nullable => 0, size => 12 },
  "abs_pm",
  { data_type => "double precision", is_nullable => 0 },
  "latitude",
  { data_type => "numeric", is_nullable => 1 },
  "longitude",
  { data_type => "numeric", is_nullable => 1 },
  "last_modified",
  { data_type => "date", is_nullable => 1 },
  "length",
  { data_type => "numeric", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 accident_risk_results

Type: has_many

Related object: L<SpatialVds::Schema::AccidentRiskResults>

=cut

__PACKAGE__->has_many(
  "accident_risk_results",
  "SpatialVds::Schema::AccidentRiskResults",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_haspems5mins

Type: has_many

Related object: L<SpatialVds::Schema::VdsHaspems5min>

=cut

__PACKAGE__->has_many(
  "vds_haspems5mins",
  "SpatialVds::Schema::VdsHaspems5min",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_stats

Type: has_many

Related object: L<SpatialVds::Schema::VdsStats>

=cut

__PACKAGE__->has_many(
  "vds_stats",
  "SpatialVds::Schema::VdsStats",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_summarystats

Type: has_many

Related object: L<SpatialVds::Schema::VdsSummarystats>

=cut

__PACKAGE__->has_many(
  "vds_summarystats",
  "SpatialVds::Schema::VdsSummarystats",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_taz_intersections

Type: has_many

Related object: L<SpatialVds::Schema::VdsTazIntersections>

=cut

__PACKAGE__->has_many(
  "vds_taz_intersections",
  "SpatialVds::Schema::VdsTazIntersections",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_taz_intersections_alts

Type: has_many

Related object: L<SpatialVds::Schema::VdsTazIntersectionsAlt>

=cut

__PACKAGE__->has_many(
  "vds_taz_intersections_alts",
  "SpatialVds::Schema::VdsTazIntersectionsAlt",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_taz_intersections_simples

Type: has_many

Related object: L<SpatialVds::Schema::VdsTazIntersectionsSimple>

=cut

__PACKAGE__->has_many(
  "vds_taz_intersections_simples",
  "SpatialVds::Schema::VdsTazIntersectionsSimple",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_wim_distances

Type: has_many

Related object: L<SpatialVds::Schema::VdsWimDistance>

=cut

__PACKAGE__->has_many(
  "vds_wim_distances",
  "SpatialVds::Schema::VdsWimDistance",
  { "foreign.vds_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x0eM1V5qfpZNknw8gQOosQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
