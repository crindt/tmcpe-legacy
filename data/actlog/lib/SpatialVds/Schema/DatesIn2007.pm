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


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g+aFqdRIt5CZZZ8r6C8BKw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
