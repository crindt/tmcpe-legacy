package TMCPE::Schema::IncidentImpactAnalysis;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tmcpe.incident_impact_analysis");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('tmcpe.incident_impact_analysis_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "analysis_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "incident_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("incident_impact_analysis_pkey", ["id"]);
__PACKAGE__->has_many(
  "incident_facility_impact_analyses",
  "TMCPE::Schema::IncidentFacilityImpactAnalysis",
  { "foreign.incident_impact_analysis_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GSDVuCQPNJLd+Nu0tO0RBw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
