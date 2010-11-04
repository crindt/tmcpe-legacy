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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:24:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RCjAzyYMvKTaeqUk+tqNhQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
