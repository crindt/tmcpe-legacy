package TMCPE::Schema::IncidentImpactAnalysis;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("incident_impact_analysis");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "version",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "analysis_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "incident_id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("incident_impact_analysis_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "incident_id",
  "TMCPE::Schema::SigalertLocationsGrailsTable",
  { cad => "incident_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-04-30 14:37:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:czn6cTidOOvoHIZ+/HKcXQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
