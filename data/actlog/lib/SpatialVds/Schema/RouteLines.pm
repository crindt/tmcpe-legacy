package SpatialVds::Schema::RouteLines;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("route_lines");
__PACKAGE__->add_columns(
  "rteid",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "routeline",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "id4",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id4");
__PACKAGE__->add_unique_constraint("route_lines_pkey", ["id4"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TiHF4jkKRtn+3DBJymDQYA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
