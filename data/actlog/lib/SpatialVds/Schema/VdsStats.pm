package SpatialVds::Schema::VdsStats;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_stats");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "stats_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("vds_id", "stats_id");
__PACKAGE__->add_unique_constraint("vds_stats_pkey", ["vds_id", "stats_id"]);
__PACKAGE__->belongs_to(
  "stats_id",
  "SpatialVds::Schema::LoopStats",
  { id => "stats_id" },
);
__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::Vds", { id => "vds_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Hd9qdtEhmlNurJ8wZjw2/g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
