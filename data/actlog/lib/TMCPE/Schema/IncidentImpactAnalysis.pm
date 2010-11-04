package TMCPE::Schema::IncidentImpactAnalysis;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::Schema::IncidentImpactAnalysis

=cut

__PACKAGE__->table("tmcpe.incident_impact_analysis");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tmcpe.incident_impact_analysis_id_seq'

=head2 analysis_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 incident_id

  data_type: 'integer'
  is_nullable: 0

=head2 version

  data_type: 'bigint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "tmcpe.incident_impact_analysis_id_seq",
  },
  "analysis_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "incident_id",
  { data_type => "integer", is_nullable => 0 },
  "version",
  { data_type => "bigint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 incident_facility_impact_analyses

Type: has_many

Related object: L<TMCPE::Schema::IncidentFacilityImpactAnalysis>

=cut

__PACKAGE__->has_many(
  "incident_facility_impact_analyses",
  "TMCPE::Schema::IncidentFacilityImpactAnalysis",
  { "foreign.incident_impact_analysis_id" => "self.id" },
  {},
);

=head2 sigalert_locations_grails_tables

Type: has_many

Related object: L<TMCPE::Schema::SigalertLocationsGrailsTable>

=cut

__PACKAGE__->has_many(
  "sigalert_locations_grails_tables",
  "TMCPE::Schema::SigalertLocationsGrailsTable",
  { "foreign.analyses_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:24:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VyqCOg28XS+Q7YWDRqDQJA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
