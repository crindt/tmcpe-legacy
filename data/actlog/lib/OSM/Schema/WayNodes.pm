package OSM::Schema::WayNodes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("way_nodes");
__PACKAGE__->add_columns(
  "way_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "node_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "sequence_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("way_id", "sequence_id");
__PACKAGE__->add_unique_constraint("pk_way_nodes", ["way_id", "sequence_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5hlg/zL9AsNHYkoI3esH3A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
