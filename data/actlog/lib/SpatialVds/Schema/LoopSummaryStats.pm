package SpatialVds::Schema::LoopSummaryStats;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("loop_summary_stats");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "estimate_time",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "interval_seconds",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "mu_volocc",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "min_volocc",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "max_volocc",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "mu_vol",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "min_vol",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "max_vol",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "sd_vol",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "sum_vol",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("loop_summary_stats_pkey", ["id"]);
__PACKAGE__->belongs_to("id", "SpatialVds::Schema::StatsIds", { id => "id" });
__PACKAGE__->has_many(
  "vds_summarystats",
  "SpatialVds::Schema::VdsSummarystats",
  { "foreign.stats_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CDkIq3CXN96sN3iKCoky4g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
