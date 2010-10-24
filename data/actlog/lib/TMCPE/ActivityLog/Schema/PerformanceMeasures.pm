package TMCPE::ActivityLog::Schema::PerformanceMeasures;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.performance_measures");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('actlog.performance_measures_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "log_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "pmtext",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 120,
  },
  "pmtype",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 80,
  },
  "blocklanes",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 80,
  },
  "detail",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "block_lanes",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("performance_measures_pkey", ["id"]);
__PACKAGE__->has_many(
  "d12_comm_log_performance_measures",
  "TMCPE::ActivityLog::Schema::D12CommLogPerformanceMeasures",
  { "foreign.tmc_performance_measures_id" => "self.id" },
);
__PACKAGE__->belongs_to(
  "log_id",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "log_id" },
);
__PACKAGE__->belongs_to(
  "log_id",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "log_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3nqQo9+V4ecIAI1S8LSNrA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
