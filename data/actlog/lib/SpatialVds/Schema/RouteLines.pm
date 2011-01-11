package SpatialVds::Schema::RouteLines;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::RouteLines

=cut

__PACKAGE__->table("route_lines");

=head1 ACCESSORS

=head2 rteid

  data_type: 'bigint'
  is_nullable: 1

=head2 routeline

  data_type: 'geometry'
  is_nullable: 1

=head2 id4

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "rteid",
  { data_type => "bigint", is_nullable => 1 },
  "routeline",
  { data_type => "geometry", is_nullable => 1 },
  "id4",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id4");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0qqoPL4ngyV5r+YCIa+aSA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
