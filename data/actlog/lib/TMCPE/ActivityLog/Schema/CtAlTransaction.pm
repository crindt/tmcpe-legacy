package TMCPE::ActivityLog::Schema::CtAlTransaction;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.ct_al_transaction");
__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "activitysubject",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "cad",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "device_direction",
  {
    data_type => "character",
    default_value => undef,
    is_nullable => 0,
    size => 1,
  },
  "device_extra",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "device_fwy",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "device_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "device_number",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "memo",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "op",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "stampdate",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "stamptime",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "status",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "unitin",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "unitout",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "via",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("keyfield");
__PACKAGE__->add_unique_constraint("ct_al_transaction_pkey", ["keyfield"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O9z++xNFfCrDKFDL5kdRyQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
