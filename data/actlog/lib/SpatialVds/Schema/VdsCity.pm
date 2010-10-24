package SpatialVds::Schema::VdsCity;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_city");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "city_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("vds_id");
__PACKAGE__->add_unique_constraint("vds_city_pkey", ["vds_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eNRkVVe5I809DmL0zZjMjA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
