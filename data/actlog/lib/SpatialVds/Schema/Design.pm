package SpatialVds::Schema::Design;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("design");
__PACKAGE__->add_columns(
  "trial_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "obs_id",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:r1jxBoBV3EbIcISo70pwtA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
