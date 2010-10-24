package SpatialVds::Schema::DatesIn2007;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("dates_in_2007");
__PACKAGE__->add_columns(
  "dates",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cU608lRiLzgY8i1Z+CKSvg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
