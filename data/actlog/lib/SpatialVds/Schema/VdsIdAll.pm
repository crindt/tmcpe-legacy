package SpatialVds::Schema::VdsIdAll;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsIdAll

=cut

__PACKAGE__->table("vds_id_all");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

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

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "cal_pm",
  { data_type => "varchar", is_nullable => 0, size => 12 },
  "abs_pm",
  { data_type => "double precision", is_nullable => 0 },
  "latitude",
  { data_type => "numeric", is_nullable => 1 },
  "longitude",
  { data_type => "numeric", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 vds_freeways

Type: has_many

Related object: L<SpatialVds::Schema::VdsFreeway>

=cut

__PACKAGE__->has_many(
  "vds_freeways",
  "SpatialVds::Schema::VdsFreeway",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_points_4269s

Type: has_many

Related object: L<SpatialVds::Schema::VdsPoints4269>

=cut

__PACKAGE__->has_many(
  "vds_points_4269s",
  "SpatialVds::Schema::VdsPoints4269",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_points_4326s

Type: has_many

Related object: L<SpatialVds::Schema::VdsPoints4326>

=cut

__PACKAGE__->has_many(
  "vds_points_4326s",
  "SpatialVds::Schema::VdsPoints4326",
  { "foreign.vds_id" => "self.id" },
  {},
);

=head2 vds_versioneds

Type: has_many

Related object: L<SpatialVds::Schema::VdsVersioned>

=cut

__PACKAGE__->has_many(
  "vds_versioneds",
  "SpatialVds::Schema::VdsVersioned",
  { "foreign.id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yrNo9ez9Ifbs8VzePFJclw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
