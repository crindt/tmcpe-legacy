package TMCPE::ActivityLog::Schema::D12CommLog;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.d12_comm_log");
__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "cad",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 60,
  },
  "unitin",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "unitout",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "via",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "op",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "device_number",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "device_extra",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "device_direction",
  {
    data_type => "character",
    default_value => "NULL::bpchar",
    is_nullable => 1,
    size => 1,
  },
  "device_fwy",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "device_name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "status",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "activitysubject",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "memo",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "imms",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "made_contact",
  {
    data_type => "character",
    default_value => "NULL::bpchar",
    is_nullable => 1,
    size => 1,
  },
  "stamp",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("keyfield");
__PACKAGE__->add_unique_constraint("d12_comm_log_pkey", ["keyfield"]);
__PACKAGE__->has_many(
  "d12_comm_log_performance_measures",
  "TMCPE::ActivityLog::Schema::D12CommLogPerformanceMeasures",
  { "foreign.comm_log_entry_p_meas_id" => "self.keyfield" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:46:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BZI2HxePsA3Y9BSYp7FtJQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
