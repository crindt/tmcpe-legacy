package TMCPE::ActivityLog::Schema::D12ActivityLog;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.d12_activity_log");
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
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 20,
  },
  "unitout",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 20,
  },
  "via",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 30,
  },
  "op",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 30,
  },
  "device_number",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "device_extra",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 5,
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
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 40,
  },
  "status",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 30,
  },
  "activitysubject",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 30,
  },
  "memo",
  {
    data_type => "text",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => undef,
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
__PACKAGE__->add_unique_constraint("d12_activity_log_pkey", ["keyfield"]);
__PACKAGE__->has_many(
  "critical_events",
  "TMCPE::ActivityLog::Schema::CriticalEvents",
  { "foreign.log_id" => "self.keyfield" },
);
__PACKAGE__->has_many(
  "incidents_first_calls",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.first_call" => "self.keyfield" },
);
__PACKAGE__->has_many(
  "incidents_sigalert_ends",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.sigalert_end" => "self.keyfield" },
);
__PACKAGE__->has_many(
  "incidents_sigalert_begins",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.sigalert_begin" => "self.keyfield" },
);
__PACKAGE__->has_many(
  "performance_measures",
  "TMCPE::ActivityLog::Schema::PerformanceMeasures",
  { "foreign.log_id" => "self.keyfield" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-27 17:06:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pbzLrJEYGcFmoKDnLtQIWg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
