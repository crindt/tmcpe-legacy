package Caltrans::ActivityLog::Schema::Test;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("test");
__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "logid",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "cadno",
  { data_type => "DOUBLE", default_value => 0, is_nullable => 0, size => 64 },
  "logtime",
  {
    data_type => "DATETIME",
    default_value => undef,
    is_nullable => 1,
    size => 19,
  },
  "logtype",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 240,
  },
  "location",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 240,
  },
  "area",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 240,
  },
  "tb",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 80,
  },
  "tbxy",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "detail",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 1,
    size => 16777215,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-03 13:21:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BKlW9CjsnVR/sK9HWAAcLQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
