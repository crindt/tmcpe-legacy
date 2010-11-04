package SpatialVds::Schema::RouteTypeMapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::RouteTypeMapping

=cut

__PACKAGE__->table("route_type_mapping");

=head1 ACCESSORS

=head2 orig

  data_type: 'text'
  is_nullable: 0

=head2 std

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "orig",
  { data_type => "text", is_nullable => 0 },
  "std",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("orig");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NazezwZrgs7AvTR4j7NsaQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
