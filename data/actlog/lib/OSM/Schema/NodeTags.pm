package OSM::Schema::NodeTags;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("node_tags");
__PACKAGE__->add_columns(
  "node_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "k",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "v",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8ioS8WjRbP9yUAVkWGhKkw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
