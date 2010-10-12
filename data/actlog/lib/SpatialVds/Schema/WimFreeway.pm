package SpatialVds::Schema::WimFreeway;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_freeway");
__PACKAGE__->add_columns(
  "wim_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "freeway_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->belongs_to(
  "wim_id",
  "SpatialVds::Schema::WimStations",
  { site_no => "wim_id" },
);
__PACKAGE__->belongs_to(
  "freeway_id",
  "SpatialVds::Schema::Freeways",
  { id => "freeway_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nI3I6yWIKTrW32CqW93AOw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
