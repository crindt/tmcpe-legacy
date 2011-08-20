package SpatialVds::Schema::WimPoints4326;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimPoints4326

=cut

__PACKAGE__->table("wim_points_4326");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 wim_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "wim_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("wim_id");

=head1 RELATIONS

=head2 gid

Type: belongs_to

Related object: L<SpatialVds::Schema::GeomPoints4326>

=cut

__PACKAGE__->belongs_to("gid", "SpatialVds::Schema::GeomPoints4326", { gid => "gid" });

=head2 wim_id

Type: belongs_to

Related object: L<SpatialVds::Schema::WimStations>

=cut

__PACKAGE__->belongs_to(
  "wim_id",
  "SpatialVds::Schema::WimStations",
  { site_no => "wim_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fNGqS4xZkwAzci7njsE2sA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
