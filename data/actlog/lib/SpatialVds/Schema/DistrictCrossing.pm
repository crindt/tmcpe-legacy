package SpatialVds::Schema::DistrictCrossing;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("district_crossing");
__PACKAGE__->add_columns(
  "district_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "crossing_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("district_id", "crossing_id");
__PACKAGE__->add_unique_constraint("district_crossing_pkey", ["district_id", "crossing_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-24 21:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EHYm/aEym+N4eyi8/HlL2g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
