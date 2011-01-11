package TMCPE::ActivityLog::Schema::D12CommLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::D12CommLog

=cut

__PACKAGE__->table("actlog.d12_comm_log");

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

  data_type: 'text'
  is_nullable: 1

=head2 unitout

  data_type: 'text'
  is_nullable: 1

=head2 via

  data_type: 'text'
  is_nullable: 1

=head2 op

  data_type: 'text'
  is_nullable: 1

=head2 device_number

  data_type: 'integer'
  is_nullable: 1

=head2 device_extra

  data_type: 'text'
  is_nullable: 1

=head2 device_direction

  data_type: 'char'
  default_value: NULL::bpchar
  is_nullable: 1
  size: 1

=head2 device_fwy

  data_type: 'integer'
  is_nullable: 1

=head2 device_name

  data_type: 'text'
  is_nullable: 1

=head2 status

  data_type: 'text'
  is_nullable: 1

=head2 activitysubject

  data_type: 'text'
  is_nullable: 1

=head2 memo

  data_type: 'text'
  is_nullable: 1

=head2 imms

  data_type: 'text'
  is_nullable: 1

=head2 made_contact

  data_type: 'char'
  default_value: NULL::bpchar
  is_nullable: 1
  size: 1

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
  { data_type => "text", is_nullable => 1 },
  "unitout",
  { data_type => "text", is_nullable => 1 },
  "via",
  { data_type => "text", is_nullable => 1 },
  "op",
  { data_type => "text", is_nullable => 1 },
  "device_number",
  { data_type => "integer", is_nullable => 1 },
  "device_extra",
  { data_type => "text", is_nullable => 1 },
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
  { data_type => "text", is_nullable => 1 },
  "status",
  { data_type => "text", is_nullable => 1 },
  "activitysubject",
  { data_type => "text", is_nullable => 1 },
  "memo",
  { data_type => "text", is_nullable => 1 },
  "imms",
  { data_type => "text", is_nullable => 1 },
  "made_contact",
  {
    data_type => "char",
    default_value => \"NULL::bpchar",
    is_nullable => 1,
    size => 1,
  },
  "stamp",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("keyfield");

=head1 RELATIONS

=head2 d12_comm_log_performance_measures

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::D12CommLogPerformanceMeasures>

=cut

__PACKAGE__->has_many(
  "d12_comm_log_performance_measures",
  "TMCPE::ActivityLog::Schema::D12CommLogPerformanceMeasures",
  { "foreign.comm_log_entry_p_meas_id" => "self.keyfield" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:12:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ISao9IVNHL7bw1xs9CcTIg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
