package SpatialVds::Schema::DesignHvyLongD7812;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("design_hvy_long_d7812");
__PACKAGE__->add_columns(
  "sampling_no",
  {
    data_type => "integer",
    default_value => "nextval('design_hvy_long_d7812_sampling_no_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "obs_no",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("sampling_no");
__PACKAGE__->add_unique_constraint("design_hvy_long_d7812_pkey", ["sampling_no"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7gs08FBmfx2ZOtdG2UvyGw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
