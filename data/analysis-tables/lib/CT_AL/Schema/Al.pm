package CT_AL::Schema::Al;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.al");
__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "stampdate",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "stamptime",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "cad",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "unitin",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "unitout",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "via",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "op",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "device_number",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "device_extra",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 5,
  },
  "device_direction",
  {
    data_type => "character",
    default_value => undef,
    is_nullable => 1,
    size => 1,
  },
  "device_fwy",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "device_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "status",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "activitysubject",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 30,
  },
  "memo",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 250,
  },
  "ts",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-25 12:13:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d6CQUd28+C5tC8NGqlSWqg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
