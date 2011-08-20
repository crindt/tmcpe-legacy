package SpatialVds::Schema::OctamLinkFlows;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamLinkFlows

=cut

__PACKAGE__->table("octam_link_flows");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 frnode

  data_type: 'integer'
  is_nullable: 1

=head2 tonode

  data_type: 'integer'
  is_nullable: 1

=head2 link_geom

  data_type: 'geometry'
  is_nullable: 1

=head2 day00

  data_type: 'double precision'
  is_nullable: 1

=head2 am00

  data_type: 'double precision'
  is_nullable: 1

=head2 pm00

  data_type: 'double precision'
  is_nullable: 1

=head2 day30

  data_type: 'double precision'
  is_nullable: 1

=head2 am30

  data_type: 'double precision'
  is_nullable: 1

=head2 pm30

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 1 },
  "frnode",
  { data_type => "integer", is_nullable => 1 },
  "tonode",
  { data_type => "integer", is_nullable => 1 },
  "link_geom",
  { data_type => "geometry", is_nullable => 1 },
  "day00",
  { data_type => "double precision", is_nullable => 1 },
  "am00",
  { data_type => "double precision", is_nullable => 1 },
  "pm00",
  { data_type => "double precision", is_nullable => 1 },
  "day30",
  { data_type => "double precision", is_nullable => 1 },
  "am30",
  { data_type => "double precision", is_nullable => 1 },
  "pm30",
  { data_type => "double precision", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OzmRnbUaRJg7fkO0XHu3nA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
