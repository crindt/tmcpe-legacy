package TMCPE::ActivityLog::Schema::AnalyzedIncidentIncidentImpactAnalysis;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::AnalyzedIncidentIncidentImpactAnalysis

=cut

__PACKAGE__->table("actlog.analyzed_incident_incident_impact_analysis");

=head1 ACCESSORS

=head2 analyzed_incident_analyses_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 incident_impact_analysis_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "analyzed_incident_analyses_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "incident_impact_analysis_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 RELATIONS

=head2 analyzed_incident_analyses_id

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::Incidents>

=cut

__PACKAGE__->belongs_to(
  "analyzed_incident_analyses_id",
  "TMCPE::ActivityLog::Schema::Incidents",
  { id => "analyzed_incident_analyses_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:19:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:b0gw1sqcUV4ZfFA60XWA9g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
