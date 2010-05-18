package SpatialVds::Schema::RouteTypeMapping;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("route_type_mapping");
__PACKAGE__->add_columns(
  "orig",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "std",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("orig");
__PACKAGE__->add_unique_constraint("route_type_mapping_pkey", ["orig"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JggF7wOfOCtSb6Ns6RKCXA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
