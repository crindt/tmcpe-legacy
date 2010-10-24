package SpatialVds::Schema::VdsFreeway;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_freeway");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "freeway_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "freeway_dir",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
);
__PACKAGE__->set_primary_key("vds_id");
__PACKAGE__->add_unique_constraint("vds_freeway_pkey", ["vds_id"]);
__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::VdsIdAll", { id => "vds_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2Hw6mlWnkFEoN8dJz5QJMQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
