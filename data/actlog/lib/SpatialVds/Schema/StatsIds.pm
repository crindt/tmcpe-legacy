package SpatialVds::Schema::StatsIds;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::StatsIds

=cut

__PACKAGE__->table("stats_ids");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'stats_ids_id_seq'

=head2 dummy

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "stats_ids_id_seq",
  },
  "dummy",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 accident_risk_results

Type: has_many

Related object: L<SpatialVds::Schema::AccidentRiskResults>

=cut

__PACKAGE__->has_many(
  "accident_risk_results",
  "SpatialVds::Schema::AccidentRiskResults",
  { "foreign.id" => "self.id" },
  {},
);

=head2 loop_stats

Type: has_many

Related object: L<SpatialVds::Schema::LoopStats>

=cut

__PACKAGE__->has_many(
  "loop_stats",
  "SpatialVds::Schema::LoopStats",
  { "foreign.id" => "self.id" },
  {},
);

=head2 loop_summary_stats

Type: has_many

Related object: L<SpatialVds::Schema::LoopSummaryStats>

=cut

__PACKAGE__->has_many(
  "loop_summary_stats",
  "SpatialVds::Schema::LoopSummaryStats",
  { "foreign.id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qlZPmT9SeHoqo+lubZqZ8g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
