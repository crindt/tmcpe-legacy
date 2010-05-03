package TMCPE::Schema::IncidentFacilityImpactAnalysis;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tmcpe.incident_facility_impact_analysis");
__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8,
    sequence => 'hibernate_sequence', auto_nextval => 1
  },
  "version",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
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
  "end_time",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("incident_facility_impact_analysis_pkey", ["id"]);
__PACKAGE__->has_many(
  "analyzed_sections",
  "TMCPE::Schema::AnalyzedSection",
  { "foreign.analysis_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-04-30 14:37:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ukXvpx4lyp71pXF87upGkA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
