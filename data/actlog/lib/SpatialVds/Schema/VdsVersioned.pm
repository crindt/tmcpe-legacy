package SpatialVds::Schema::VdsVersioned;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_versioned");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "lanes",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "segment_length",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "version",
  { data_type => "date", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id", "version");
__PACKAGE__->add_unique_constraint("vds_versioned_pkey", ["id", "version"]);
__PACKAGE__->belongs_to("id", "SpatialVds::Schema::VdsIdAll", { id => "id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-27 17:06:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5m3AUQhm2gcOjPhTpYY3nA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
