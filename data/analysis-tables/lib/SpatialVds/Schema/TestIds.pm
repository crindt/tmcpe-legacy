package SpatialVds::Schema::TestIds;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("test_ids");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type => "integer",
    default_value => "nextval('test_ids_gid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "dummy",
  { data_type => "integer", default_value => 1, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("gid");
__PACKAGE__->add_unique_constraint("test_ids_pkey", ["gid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TmcWgIdP4VMkl4JHHBfInw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
