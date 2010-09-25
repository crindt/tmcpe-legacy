package SpatialVds::Schema::OrderedNodes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("ordered_nodes");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-24 21:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:klv0ID7mywd6fAgMKb4SHA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
