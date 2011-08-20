package SpatialVds::Schema::OnrTazMatchTbl;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OnrTazMatchTbl

=cut

__PACKAGE__->table("onr_taz_match_tbl");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 taz_id

  data_type: 'integer'
  is_nullable: 1

=head2 mindist

  data_type: 'double precision'
  is_nullable: 1

=head2 manhdist

  data_type: 'double precision'
  is_nullable: 1

=head2 linegeom

  data_type: 'geometry'
  is_nullable: 1

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'onr_taz_match_tbl_gid_seq'

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "taz_id",
  { data_type => "integer", is_nullable => 1 },
  "mindist",
  { data_type => "double precision", is_nullable => 1 },
  "manhdist",
  { data_type => "double precision", is_nullable => 1 },
  "linegeom",
  { data_type => "geometry", is_nullable => 1 },
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "onr_taz_match_tbl_gid_seq",
  },
);
__PACKAGE__->set_primary_key("gid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z4PIWeijmTpADn34ciIHTw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
