package SpatialVds::Schema::WimCounty;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_county");
__PACKAGE__->add_columns(
  "wim_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "county_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->belongs_to(
  "wim_id",
  "SpatialVds::Schema::WimStations",
  { site_no => "wim_id" },
);
__PACKAGE__->belongs_to(
  "county_id",
  "SpatialVds::Schema::Counties",
  { id => "county_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bZ880pbse4bv1pasnqMV9w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
