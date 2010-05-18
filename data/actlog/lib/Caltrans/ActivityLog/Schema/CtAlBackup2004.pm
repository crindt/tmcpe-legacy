package Caltrans::ActivityLog::Schema::CtAlBackup2004;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("CT_AL_BackUp_2004");
__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "stampdate",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 10 },
  "stamptime",
  { data_type => "TIME", default_value => undef, is_nullable => 1, size => 8 },
  "cad",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "unitin",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "unitout",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "via",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "op",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "device_number",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 4 },
  "device_extra",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 1, size => 5 },
  "device_direction",
  { data_type => "CHAR", default_value => undef, is_nullable => 1, size => 1 },
  "device_fwy",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 4 },
  "device_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "status",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "activitysubject",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "memo",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 1,
    size => 16777215,
  },
);
__PACKAGE__->set_primary_key("keyfield");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-03 13:21:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZbU1vZq8OZ1Xxg/UgqSAJg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
