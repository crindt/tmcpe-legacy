package SpatialVds::Schema::AccidentRiskResults;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("accident_risk_results");
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
  "model_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 100,
  },
  "odds",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "accident_risk_results_vds_id_key",
  ["vds_id", "estimate_time", "model_name"],
);
__PACKAGE__->add_unique_constraint("accident_risk_results_pkey", ["id"]);
__PACKAGE__->belongs_to("id", "SpatialVds::Schema::StatsIds", { id => "id" });
__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::Vds", { id => "vds_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fst0ROQKEUSiObE+dlibFA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
