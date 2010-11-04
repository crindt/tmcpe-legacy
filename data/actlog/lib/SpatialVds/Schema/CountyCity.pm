package SpatialVds::Schema::CountyCity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::CountyCity

=cut

__PACKAGE__->table("county_city");

=head1 ACCESSORS

=head2 city_id

  data_type: 'integer'
  is_nullable: 0

=head2 county_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "city_id",
  { data_type => "integer", is_nullable => 0 },
  "county_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("city_id", "county_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+sQo9VzKOqeEuJ38p/SrRg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
