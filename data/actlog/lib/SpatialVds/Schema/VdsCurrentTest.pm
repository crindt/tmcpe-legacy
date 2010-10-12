package SpatialVds::Schema::VdsCurrentTest;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_current_test");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "version",
  { data_type => "date", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id", "version");
__PACKAGE__->add_unique_constraint("vds_current_test_pkey", ["id", "version"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MjB+Ki+J9+4pVEYtwFjEkQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
