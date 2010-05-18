package SpatialVds::Schema::OctamOnRamps;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_on_ramps");
__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+RW7pg6LnQpudPDYCrJ8DA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
