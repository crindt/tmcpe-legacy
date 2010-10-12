package SpatialVds::Schema::Calendar;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("calendar");
__PACKAGE__->add_columns(
  "calendar_key",
  { data_type => "date", default_value => undef, is_nullable => 0, size => 4 },
  "dow",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "dom",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "year",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "holiday",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
);
__PACKAGE__->set_primary_key("calendar_key");
__PACKAGE__->add_unique_constraint("calendar_pkey", ["calendar_key"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k93feJbeCupw92m58F9+qg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
