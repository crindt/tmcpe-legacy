package TMCPE::ActivityLog::Schema::PerformanceMeasures;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::PerformanceMeasures

=cut

__PACKAGE__->table("actlog.performance_measures");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'actlog.performance_measures_id_seq'

=head2 log_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 pmtext

  data_type: 'varchar'
  is_nullable: 0
  size: 120

=head2 pmtype

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 blocklanes

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 detail

  data_type: 'text'
  is_nullable: 1

=head2 block_lanes

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "actlog.performance_measures_id_seq",
  },
  "log_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "pmtext",
  { data_type => "varchar", is_nullable => 0, size => 120 },
  "pmtype",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "blocklanes",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "detail",
  { data_type => "text", is_nullable => 1 },
  "block_lanes",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 d12_comm_log_censored_performance_measures

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::D12CommLogCensoredPerformanceMeasures>

=cut

__PACKAGE__->has_many(
  "d12_comm_log_censored_performance_measures",
  "TMCPE::ActivityLog::Schema::D12CommLogCensoredPerformanceMeasures",
  { "foreign.tmc_performance_measures_id" => "self.id" },
  {},
);

=head2 d12_comm_log_performance_measures

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::D12CommLogPerformanceMeasures>

=cut

__PACKAGE__->has_many(
  "d12_comm_log_performance_measures",
  "TMCPE::ActivityLog::Schema::D12CommLogPerformanceMeasures",
  { "foreign.tmc_performance_measures_id" => "self.id" },
  {},
);

=head2 log_id

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "log_id",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "log_id" },
);

=head2 log_id

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "log_id",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "log_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:06:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZL0m414bWXUGRmw0+nGzag


# You can replace this text with custom content, and it will be preserved on regeneration
1;
