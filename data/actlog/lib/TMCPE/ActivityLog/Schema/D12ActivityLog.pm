package TMCPE::ActivityLog::Schema::D12ActivityLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::D12ActivityLog

=cut

__PACKAGE__->table("actlog.d12_activity_log");

=head1 ACCESSORS

=head2 keyfield

  data_type: 'integer'
  is_nullable: 0

=head2 cad

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 60

=head2 unitin

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 20

=head2 unitout

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 20

=head2 via

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 30

=head2 op

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 30

=head2 device_number

  data_type: 'integer'
  is_nullable: 1

=head2 device_extra

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 5

=head2 device_direction

  data_type: 'char'
  default_value: NULL::bpchar
  is_nullable: 1
  size: 1

=head2 device_fwy

  data_type: 'integer'
  is_nullable: 1

=head2 device_name

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 40

=head2 status

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 30

=head2 activitysubject

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 30

=head2 memo

  data_type: 'text'
  default_value: NULL::character varying
  is_nullable: 1

=head2 stamp

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", is_nullable => 0 },
  "cad",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 60,
  },
  "unitin",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 20,
  },
  "unitout",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 20,
  },
  "via",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 30,
  },
  "op",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 30,
  },
  "device_number",
  { data_type => "integer", is_nullable => 1 },
  "device_extra",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 5,
  },
  "device_direction",
  {
    data_type => "char",
    default_value => \"NULL::bpchar",
    is_nullable => 1,
    size => 1,
  },
  "device_fwy",
  { data_type => "integer", is_nullable => 1 },
  "device_name",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 40,
  },
  "status",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 30,
  },
  "activitysubject",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 30,
  },
  "memo",
  {
    data_type     => "text",
    default_value => \"NULL::character varying",
    is_nullable   => 1,
  },
  "stamp",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("keyfield");

=head1 RELATIONS

=head2 critical_events

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::CriticalEvents>

=cut

__PACKAGE__->has_many(
  "critical_events",
  "TMCPE::ActivityLog::Schema::CriticalEvents",
  { "foreign.log_id" => "self.keyfield" },
  {},
);

=head2 incidents_incident_clears

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::Incidents>

=cut

__PACKAGE__->has_many(
  "incidents_incident_clears",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.incident_clear" => "self.keyfield" },
  {},
);

=head2 incidents_first_calls

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::Incidents>

=cut

__PACKAGE__->has_many(
  "incidents_first_calls",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.first_call" => "self.keyfield" },
  {},
);

=head2 incidents_verifications

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::Incidents>

=cut

__PACKAGE__->has_many(
  "incidents_verifications",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.verification" => "self.keyfield" },
  {},
);

=head2 incidents_sigalert_ends

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::Incidents>

=cut

__PACKAGE__->has_many(
  "incidents_sigalert_ends",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.sigalert_end" => "self.keyfield" },
  {},
);

=head2 incidents_sigalert_begins

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::Incidents>

=cut

__PACKAGE__->has_many(
  "incidents_sigalert_begins",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.sigalert_begin" => "self.keyfield" },
  {},
);

=head2 incidents_lanes_clears

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::Incidents>

=cut

__PACKAGE__->has_many(
  "incidents_lanes_clears",
  "TMCPE::ActivityLog::Schema::Incidents",
  { "foreign.lanes_clear" => "self.keyfield" },
  {},
);

=head2 performance_measures_log_ids

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::PerformanceMeasures>

=cut

__PACKAGE__->has_many(
  "performance_measures_log_ids",
  "TMCPE::ActivityLog::Schema::PerformanceMeasures",
  { "foreign.log_id" => "self.keyfield" },
  {},
);

=head2 performance_measures_log_ids

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::PerformanceMeasures>

=cut

__PACKAGE__->has_many(
  "performance_measures_log_ids",
  "TMCPE::ActivityLog::Schema::PerformanceMeasures",
  { "foreign.log_id" => "self.keyfield" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5/IsAuWreq6InRJHTPrrOA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
