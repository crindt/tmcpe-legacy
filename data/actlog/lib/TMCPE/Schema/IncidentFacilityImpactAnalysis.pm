package TMCPE::Schema::IncidentFacilityImpactAnalysis;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tmcpe.incident_facility_impact_analysis");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('tmcpe.incident_facility_impact_analysis_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "start_time",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "total_delay",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "location_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "incident_impact_analysis_id",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "end_time",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "net_delay",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "avg_delay",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "band",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "version",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("incident_facility_impact_analysis_pkey", ["id"]);
__PACKAGE__->has_many(
  "analyzed_sections",
  "TMCPE::Schema::AnalyzedSection",
  { "foreign.analysis_id" => "self.id" },
);
__PACKAGE__->belongs_to(
  "incident_impact_analysis_id",
  "TMCPE::Schema::IncidentImpactAnalysis",
  { id => "incident_impact_analysis_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 23:55:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hm9rQGBtnkmv7XTGKY4u/A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
