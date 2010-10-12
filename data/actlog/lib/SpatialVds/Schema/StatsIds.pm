package SpatialVds::Schema::StatsIds;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("stats_ids");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('stats_ids_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "dummy",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("stats_ids_pkey", ["id"]);
__PACKAGE__->has_many(
  "accident_risk_results",
  "SpatialVds::Schema::AccidentRiskResults",
  { "foreign.id" => "self.id" },
);
__PACKAGE__->has_many(
  "loop_stats",
  "SpatialVds::Schema::LoopStats",
  { "foreign.id" => "self.id" },
);
__PACKAGE__->has_many(
  "loop_summary_stats",
  "SpatialVds::Schema::LoopSummaryStats",
  { "foreign.id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TsK2szV+/nXL6kxt3z7Npw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
