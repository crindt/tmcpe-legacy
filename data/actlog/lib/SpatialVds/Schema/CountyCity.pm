package SpatialVds::Schema::CountyCity;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("county_city");
__PACKAGE__->add_columns(
  "city_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "county_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("city_id", "county_id");
__PACKAGE__->add_unique_constraint("county_city_pkey", ["city_id", "county_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 23:55:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:q5o5ruUVtWlZYs+2r1eJtQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
