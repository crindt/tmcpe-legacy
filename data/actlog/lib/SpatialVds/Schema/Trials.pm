package SpatialVds::Schema::Trials;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("trials");
__PACKAGE__->add_columns(
  "trial_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "avg_total_axle_spacing",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xDgIspLfHpacS/CVoh/fqQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
