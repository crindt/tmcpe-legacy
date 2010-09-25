package SpatialVds::Schema::WimLaneDir;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_lane_dir");
__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "direction",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 1,
  },
  "lane_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "wim_lane_no",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "facility",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("site_no", "direction", "lane_no");
__PACKAGE__->add_unique_constraint("wim_lane_dir_pkey", ["site_no", "direction", "lane_no"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-24 21:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QmOi1XAK1eQaSMxzFh3FUQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
