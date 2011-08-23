package TMCPE::ActivityLog::Schema::Incidents;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::Incidents

=cut

__PACKAGE__->table("actlog.incidents");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'actlog.incidents_id_seq'

=head2 cad

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 start_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 first_call

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 sigalert_begin

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 sigalert_end

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 location_vdsid

  data_type: 'integer'
  is_nullable: 1

=head2 event_type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 location_geom

  data_type: 'geometry'
  is_nullable: 1

=head2 verification

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 lanes_clear

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 incident_clear

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 best_geom

  data_type: 'bytea'
  is_nullable: 1

=head2 class

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 active_analysis_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "actlog.incidents_id_seq",
  },
  "cad",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "start_time",
  { data_type => "timestamp", is_nullable => 1 },
  "first_call",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "sigalert_begin",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "sigalert_end",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "location_vdsid",
  { data_type => "integer", is_nullable => 1 },
  "event_type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "location_geom",
  { data_type => "geometry", is_nullable => 1 },
  "verification",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "lanes_clear",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "incident_clear",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "best_geom",
  { data_type => "bytea", is_nullable => 1 },
  "class",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "active_analysis_id",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("incidents_cad_key", ["cad"]);

=head1 RELATIONS

=head2 analyzed_incident_incident_impact_analyses

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::AnalyzedIncidentIncidentImpactAnalysis>

=cut

__PACKAGE__->has_many(
  "analyzed_incident_incident_impact_analyses",
  "TMCPE::ActivityLog::Schema::AnalyzedIncidentIncidentImpactAnalysis",
  { "foreign.analyzed_incident_analyses_id" => "self.id" },
  {},
);

=head2 incident_clear

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "incident_clear",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "incident_clear" },
);

=head2 first_call

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "first_call",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "first_call" },
);

=head2 verification

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "verification",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "verification" },
);

=head2 sigalert_end

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "sigalert_end",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "sigalert_end" },
);

=head2 sigalert_begin

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "sigalert_begin",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "sigalert_begin" },
);

=head2 lanes_clear

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "lanes_clear",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "lanes_clear" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:19:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PGtlSiLAGmdV668jmtxsqw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
