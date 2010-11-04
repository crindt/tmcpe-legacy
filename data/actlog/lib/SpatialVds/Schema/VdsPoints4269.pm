package SpatialVds::Schema::VdsPoints4269;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsPoints4269

=cut

__PACKAGE__->table("vds_points_4269");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 vds_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "vds_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("vds_id");

=head1 RELATIONS

=head2 vds_id

Type: belongs_to

Related object: L<SpatialVds::Schema::VdsIdAll>

=cut

__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::VdsIdAll", { id => "vds_id" });

=head2 gid

Type: belongs_to

Related object: L<SpatialVds::Schema::GeomPoints4269>

=cut

__PACKAGE__->belongs_to("gid", "SpatialVds::Schema::GeomPoints4269", { gid => "gid" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:njXE9VZw5QBhoRifnE4p9w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
