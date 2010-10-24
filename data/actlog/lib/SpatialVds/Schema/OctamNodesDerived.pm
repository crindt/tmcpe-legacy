package SpatialVds::Schema::OctamNodesDerived;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_nodes_derived");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("octam_nodes_derived_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rbErAjiCv/+U8JdWjyTOuQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
