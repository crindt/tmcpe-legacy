package TMCPE::ActivityLog::Schema::D12CommLogCensoredPerformanceMeasures;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::D12CommLogCensoredPerformanceMeasures

=cut

__PACKAGE__->table("actlog.d12_comm_log_censored_performance_measures");

=head1 ACCESSORS

=head2 comm_log_entry_p_meas_id

  data_type: 'integer'
  is_nullable: 1

=head2 tmc_performance_measures_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "comm_log_entry_p_meas_id",
  { data_type => "integer", is_nullable => 1 },
  "tmc_performance_measures_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 RELATIONS

=head2 tmc_performance_measures_id

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::PerformanceMeasures>

=cut

__PACKAGE__->belongs_to(
  "tmc_performance_measures_id",
  "TMCPE::ActivityLog::Schema::PerformanceMeasures",
  { id => "tmc_performance_measures_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:19:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YfjTmuniwBf1KvFeArFERg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
