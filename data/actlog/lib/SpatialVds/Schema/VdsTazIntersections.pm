package SpatialVds::Schema::VdsTazIntersections;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsTazIntersections

=cut

__PACKAGE__->table("vds_taz_intersections");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'vds_taz_intersections_gid_seq'

=head2 vds_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 taz_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 fraction

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "vds_taz_intersections_gid_seq",
  },
  "vds_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "taz_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "fraction",
  { data_type => "real", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");

=head1 RELATIONS

=head2 taz_id

Type: belongs_to

Related object: L<SpatialVds::Schema::OctamTaz>

=cut

__PACKAGE__->belongs_to(
  "taz_id",
  "SpatialVds::Schema::OctamTaz",
  { taz_id => "taz_id" },
);

=head2 vds_id

Type: belongs_to

Related object: L<SpatialVds::Schema::Vds>

=cut

__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::Vds", { id => "vds_id" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zimdA86XH+SgSpNQcnWOrQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
