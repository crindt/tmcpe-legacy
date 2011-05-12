package TBMAP::Schema::VdsSegmentGeometry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TBMAP::Schema::VdsSegmentGeometry

=cut

__PACKAGE__->table("tbmap.vds_segment_geometry");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 adj_pm

  data_type: 'double precision'
  is_nullable: 1

=head2 rel

  data_type: 'integer'
  is_nullable: 1

=head2 raw_seggeom

  data_type: 'geometry'
  is_nullable: 1

=head2 seggeom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "adj_pm",
  { data_type => "double precision", is_nullable => 1 },
  "rel",
  { data_type => "integer", is_nullable => 1 },
  "raw_seggeom",
  { data_type => "geometry", is_nullable => 1 },
  "seggeom",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:34:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XiB2qknwyTg0cPvIq30KDg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
