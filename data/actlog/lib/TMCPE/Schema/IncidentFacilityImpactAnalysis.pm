package TMCPE::Schema::IncidentFacilityImpactAnalysis;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::Schema::IncidentFacilityImpactAnalysis

=cut

__PACKAGE__->table("tmcpe.incident_facility_impact_analysis");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tmcpe.incident_facility_impact_analysis_id_seq'

=head2 start_time

  data_type: 'timestamp'
  is_nullable: 0

=head2 total_delay

  data_type: 'double precision'
  is_nullable: 1

=head2 location_id

  data_type: 'integer'
  is_nullable: 0

=head2 incident_impact_analysis_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 end_time

  data_type: 'timestamp'
  is_nullable: 0

=head2 net_delay

  data_type: 'double precision'
  is_nullable: 1

=head2 avg_delay

  data_type: 'double precision'
  is_nullable: 1

=head2 band

  data_type: 'double precision'
  is_nullable: 1

=head2 version

  data_type: 'bigint'
  is_nullable: 1

=head2 d12delay

  data_type: 'double precision'
  is_nullable: 1

=head2 max_incident_speed

  data_type: 'double precision'
  is_nullable: 1

=head2 command_line

  data_type: 'varchar'
  is_nullable: 1
  size: 2048

=head2 bias

  data_type: 'double precision'
  is_nullable: 1

=head2 bound_incident_time

  data_type: 'boolean'
  is_nullable: 1

=head2 d12delay_speed

  data_type: 'double precision'
  is_nullable: 1

=head2 downstream_window

  data_type: 'double precision'
  is_nullable: 1

=head2 gams_input_file

  data_type: 'bytea'
  is_nullable: 1

=head2 gams_output_file

  data_type: 'bytea'
  is_nullable: 1

=head2 limit_clearing_shockwave

  data_type: 'double precision'
  is_nullable: 1

=head2 limit_loading_shockwave

  data_type: 'double precision'
  is_nullable: 1

=head2 min_observation_percent

  data_type: 'double precision'
  is_nullable: 1

=head2 post_window

  data_type: 'double precision'
  is_nullable: 1

=head2 pre_window

  data_type: 'double precision'
  is_nullable: 1

=head2 unknown_evidence_value

  data_type: 'double precision'
  is_nullable: 1

=head2 upstream_window

  data_type: 'double precision'
  is_nullable: 1

=head2 weight_for_distance

  data_type: 'double precision'
  is_nullable: 1

=head2 weight_for_length

  data_type: 'boolean'
  is_nullable: 1

=head2 space_restricted

  data_type: 'boolean'
  is_nullable: 1

=head2 time_restricted

  data_type: 'boolean'
  is_nullable: 1

=head2 solution_space_bounded

  data_type: 'boolean'
  is_nullable: 1

=head2 solution_time_bounded

  data_type: 'boolean'
  is_nullable: 1

=head2 first_call

  data_type: 'timestamp'
  is_nullable: 1

=head2 incident_clear

  data_type: 'timestamp'
  is_nullable: 1

=head2 lanes_clear

  data_type: 'timestamp'
  is_nullable: 1

=head2 verification

  data_type: 'timestamp'
  is_nullable: 1

=head2 computed_location_id

  data_type: 'integer'
  is_nullable: 1

=head2 computed_start

  data_type: 'timestamp'
  is_nullable: 1

=head2 computed_start_location_id

  data_type: 'integer'
  is_nullable: 1

=head2 computed_start_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 incident_clear_location

  data_type: 'timestamp'
  is_nullable: 1

=head2 incident_clear_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 computed_incident_clear_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 computed_delay2

  data_type: 'double precision'
  is_nullable: 1

=head2 computed_diversion

  data_type: 'double precision'
  is_nullable: 1

=head2 computed_maxq

  data_type: 'double precision'
  is_nullable: 1

=head2 computed_maxq_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 bad_solution

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 min_miles_observed

  data_type: 'double precision'
  is_nullable: 1

=head2 min_miles_total

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "tmcpe.incident_facility_impact_analysis_id_seq",
  },
  "start_time",
  { data_type => "timestamp", is_nullable => 0 },
  "total_delay",
  { data_type => "double precision", is_nullable => 1 },
  "location_id",
  { data_type => "integer", is_nullable => 0 },
  "incident_impact_analysis_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "end_time",
  { data_type => "timestamp", is_nullable => 0 },
  "net_delay",
  { data_type => "double precision", is_nullable => 1 },
  "avg_delay",
  { data_type => "double precision", is_nullable => 1 },
  "band",
  { data_type => "double precision", is_nullable => 1 },
  "version",
  { data_type => "bigint", is_nullable => 1 },
  "d12delay",
  { data_type => "double precision", is_nullable => 1 },
  "max_incident_speed",
  { data_type => "double precision", is_nullable => 1 },
  "command_line",
  { data_type => "varchar", is_nullable => 1, size => 2048 },
  "bias",
  { data_type => "double precision", is_nullable => 1 },
  "bound_incident_time",
  { data_type => "boolean", is_nullable => 1 },
  "d12delay_speed",
  { data_type => "double precision", is_nullable => 1 },
  "downstream_window",
  { data_type => "double precision", is_nullable => 1 },
  "gams_input_file",
  { data_type => "bytea", is_nullable => 1 },
  "gams_output_file",
  { data_type => "bytea", is_nullable => 1 },
  "limit_clearing_shockwave",
  { data_type => "double precision", is_nullable => 1 },
  "limit_loading_shockwave",
  { data_type => "double precision", is_nullable => 1 },
  "min_observation_percent",
  { data_type => "double precision", is_nullable => 1 },
  "post_window",
  { data_type => "double precision", is_nullable => 1 },
  "pre_window",
  { data_type => "double precision", is_nullable => 1 },
  "unknown_evidence_value",
  { data_type => "double precision", is_nullable => 1 },
  "upstream_window",
  { data_type => "double precision", is_nullable => 1 },
  "weight_for_distance",
  { data_type => "double precision", is_nullable => 1 },
  "weight_for_length",
  { data_type => "boolean", is_nullable => 1 },
  "space_restricted",
  { data_type => "boolean", is_nullable => 1 },
  "time_restricted",
  { data_type => "boolean", is_nullable => 1 },
  "solution_space_bounded",
  { data_type => "boolean", is_nullable => 1 },
  "solution_time_bounded",
  { data_type => "boolean", is_nullable => 1 },
  "first_call",
  { data_type => "timestamp", is_nullable => 1 },
  "incident_clear",
  { data_type => "timestamp", is_nullable => 1 },
  "lanes_clear",
  { data_type => "timestamp", is_nullable => 1 },
  "verification",
  { data_type => "timestamp", is_nullable => 1 },
  "computed_location_id",
  { data_type => "integer", is_nullable => 1 },
  "computed_start",
  { data_type => "timestamp", is_nullable => 1 },
  "computed_start_location_id",
  { data_type => "integer", is_nullable => 1 },
  "computed_start_time",
  { data_type => "timestamp", is_nullable => 1 },
  "incident_clear_location",
  { data_type => "timestamp", is_nullable => 1 },
  "incident_clear_time",
  { data_type => "timestamp", is_nullable => 1 },
  "computed_incident_clear_time",
  { data_type => "timestamp", is_nullable => 1 },
  "computed_delay2",
  { data_type => "double precision", is_nullable => 1 },
  "computed_diversion",
  { data_type => "double precision", is_nullable => 1 },
  "computed_maxq",
  { data_type => "double precision", is_nullable => 1 },
  "computed_maxq_time",
  { data_type => "timestamp", is_nullable => 1 },
  "bad_solution",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "min_miles_observed",
  { data_type => "double precision", is_nullable => 1 },
  "min_miles_total",
  { data_type => "double precision", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 analyzed_sections

Type: has_many

Related object: L<TMCPE::Schema::AnalyzedSection>

=cut

__PACKAGE__->has_many(
  "analyzed_sections",
  "TMCPE::Schema::AnalyzedSection",
  { "foreign.analysis_id" => "self.id" },
  {},
);

=head2 incident_impact_analysis_id

Type: belongs_to

Related object: L<TMCPE::Schema::IncidentImpactAnalysis>

=cut

__PACKAGE__->belongs_to(
  "incident_impact_analysis_id",
  "TMCPE::Schema::IncidentImpactAnalysis",
  { id => "incident_impact_analysis_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:19:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Lf99rqQyRYxCEXqqz0Ykfg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
