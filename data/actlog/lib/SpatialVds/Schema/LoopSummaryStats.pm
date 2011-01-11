package SpatialVds::Schema::LoopSummaryStats;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::LoopSummaryStats

=cut

__PACKAGE__->table("loop_summary_stats");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 estimate_time

  data_type: 'timestamp'
  is_nullable: 0

=head2 interval_seconds

  data_type: 'integer'
  is_nullable: 0

=head2 mu_volocc

  data_type: 'numeric'
  is_nullable: 0

=head2 min_volocc

  data_type: 'numeric'
  is_nullable: 0

=head2 max_volocc

  data_type: 'numeric'
  is_nullable: 0

=head2 mu_vol

  data_type: 'numeric'
  is_nullable: 0

=head2 min_vol

  data_type: 'numeric'
  is_nullable: 0

=head2 max_vol

  data_type: 'numeric'
  is_nullable: 0

=head2 sd_vol

  data_type: 'numeric'
  is_nullable: 0

=head2 sum_vol

  data_type: 'numeric'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "estimate_time",
  { data_type => "timestamp", is_nullable => 0 },
  "interval_seconds",
  { data_type => "integer", is_nullable => 0 },
  "mu_volocc",
  { data_type => "numeric", is_nullable => 0 },
  "min_volocc",
  { data_type => "numeric", is_nullable => 0 },
  "max_volocc",
  { data_type => "numeric", is_nullable => 0 },
  "mu_vol",
  { data_type => "numeric", is_nullable => 0 },
  "min_vol",
  { data_type => "numeric", is_nullable => 0 },
  "max_vol",
  { data_type => "numeric", is_nullable => 0 },
  "sd_vol",
  { data_type => "numeric", is_nullable => 0 },
  "sum_vol",
  { data_type => "numeric", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<SpatialVds::Schema::StatsIds>

=cut

__PACKAGE__->belongs_to("id", "SpatialVds::Schema::StatsIds", { id => "id" });

=head2 vds_summarystats

Type: has_many

Related object: L<SpatialVds::Schema::VdsSummarystats>

=cut

__PACKAGE__->has_many(
  "vds_summarystats",
  "SpatialVds::Schema::VdsSummarystats",
  { "foreign.stats_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i+ESJfkhTW4i6DmS1q6DsA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
