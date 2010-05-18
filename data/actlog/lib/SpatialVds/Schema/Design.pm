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


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mxFBuNSsrKx26UqA1jYz4g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
