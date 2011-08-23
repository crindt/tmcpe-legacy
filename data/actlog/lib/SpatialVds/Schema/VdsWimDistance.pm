package SpatialVds::Schema::VdsWimDistance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsWimDistance

=cut

__PACKAGE__->table("vds_wim_distance");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 wim_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 distance

  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "wim_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "distance",
  { data_type => "numeric", is_nullable => 1 },
);

=head1 RELATIONS

=head2 wim_id

Type: belongs_to

Related object: L<SpatialVds::Schema::WimStations>

=cut

__PACKAGE__->belongs_to(
  "wim_id",
  "SpatialVds::Schema::WimStations",
  { site_no => "wim_id" },
);

=head2 vds_id

Type: belongs_to

Related object: L<SpatialVds::Schema::Vds>

=cut

__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::Vds", { id => "vds_id" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vuBiBV5ARL+PbomXZpH2bQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
