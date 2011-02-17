package SpatialVds::Schema::WimPoints4269;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimPoints4269

=cut

__PACKAGE__->table("wim_points_4269");

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

=head2 wim_id

Type: belongs_to

Related object: L<SpatialVds::Schema::WimStations>

=cut

__PACKAGE__->belongs_to(
  "wim_id",
  "SpatialVds::Schema::WimStations",
  { site_no => "wim_id" },
);

=head2 gid

Type: belongs_to

Related object: L<SpatialVds::Schema::GeomPoints4269>

=cut

__PACKAGE__->belongs_to("gid", "SpatialVds::Schema::GeomPoints4269", { gid => "gid" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5IRAdbpLw0t8mZIhQ99USw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
