package OSM::Schema::Nodes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("nodes");
__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "version",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "tstamp",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "changeset_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_nodes", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dpmOd7rkAARgCyhM1gZxaw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
