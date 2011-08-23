package SpatialVds::Schema::OctamTazGeom;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamTazGeom

=cut

__PACKAGE__->table("octam_taz_geom");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'octam_taz_gid_seq'

=head2 taz_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 area

  data_type: 'double precision'
  is_nullable: 1

=head2 id1

  data_type: 'integer'
  is_nullable: 1

=head2 area1

  data_type: 'double precision'
  is_nullable: 1

=head2 perimeter

  data_type: 'double precision'
  is_nullable: 1

=head2 octam3_reg

  data_type: 'integer'
  is_nullable: 1

=head2 octam3_re1

  data_type: 'integer'
  is_nullable: 1

=head2 taz

  data_type: 'integer'
  is_nullable: 1

=head2 caa_

  data_type: 'integer'
  is_nullable: 1

=head2 rsa_

  data_type: 'integer'
  is_nullable: 1

=head2 tier1_

  data_type: 'integer'
  is_nullable: 1

=head2 the_geom

  data_type: 'geometry'
  is_nullable: 1

=head2 geom_2771

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "octam_taz_gid_seq",
  },
  "taz_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "area",
  { data_type => "double precision", is_nullable => 1 },
  "id1",
  { data_type => "integer", is_nullable => 1 },
  "area1",
  { data_type => "double precision", is_nullable => 1 },
  "perimeter",
  { data_type => "double precision", is_nullable => 1 },
  "octam3_reg",
  { data_type => "integer", is_nullable => 1 },
  "octam3_re1",
  { data_type => "integer", is_nullable => 1 },
  "taz",
  { data_type => "integer", is_nullable => 1 },
  "caa_",
  { data_type => "integer", is_nullable => 1 },
  "rsa_",
  { data_type => "integer", is_nullable => 1 },
  "tier1_",
  { data_type => "integer", is_nullable => 1 },
  "the_geom",
  { data_type => "geometry", is_nullable => 1 },
  "geom_2771",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("taz_id_unique", ["taz_id"]);

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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UadDfFN2CQhYIfygMcQOxg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
