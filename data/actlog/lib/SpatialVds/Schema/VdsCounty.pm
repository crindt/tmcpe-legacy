package SpatialVds::Schema::VdsCounty;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_county");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "county_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("vds_id");
__PACKAGE__->add_unique_constraint("vds_county_pkey", ["vds_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F7SHenik+2oQfWNIaVyK0w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
