package TMCPE::ActivityLog::Schema::FullIncidentsCalcsIncidentImpactAnalysis;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::FullIncidentsCalcsIncidentImpactAnalysis

=cut

__PACKAGE__->table("actlog.full_incidents_calcs_incident_impact_analysis");

=head1 ACCESSORS

=head2 incident_analyses_id

  data_type: 'integer'
  is_nullable: 1

=head2 incident_impact_analysis_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "incident_analyses_id",
  { data_type => "integer", is_nullable => 1 },
  "incident_impact_analysis_id",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:19:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+9HmRqAE03xxmuWTjtc4Tw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
