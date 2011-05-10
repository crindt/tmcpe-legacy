package SpatialVds::Schema::VdsRouteRelation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsRouteRelation

=cut

__PACKAGE__->table("vds_route_relation");

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

=head2 vdssnap

  data_type: 'geometry'
  is_nullable: 1

=head2 dist

  data_type: 'double precision'
  is_nullable: 1

=head2 line

  data_type: 'geometry'
  is_nullable: 1

=head2 vds_sequence_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'vds_route_relation_vds_sequence_id_seq'

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "adj_pm",
  { data_type => "double precision", is_nullable => 1 },
  "rel",
  { data_type => "integer", is_nullable => 1 },
  "vdssnap",
  { data_type => "geometry", is_nullable => 1 },
  "dist",
  { data_type => "double precision", is_nullable => 1 },
  "line",
  { data_type => "geometry", is_nullable => 1 },
  "vds_sequence_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "vds_route_relation_vds_sequence_id_seq",
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yJYUjz7DpWokmGUNcQeWyQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
