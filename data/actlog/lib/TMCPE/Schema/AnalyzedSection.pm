package TMCPE::Schema::AnalyzedSection;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::Schema::AnalyzedSection

=cut

__PACKAGE__->table("tmcpe.analyzed_section");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tmcpe.analyzed_section_id_seq'

=head2 analysis_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 section_id

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
    sequence          => "tmcpe.analyzed_section_id_seq",
  },
  "analysis_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "section_id",
  { data_type => "integer", is_nullable => 0 },
  "version",
  { data_type => "bigint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 analysis_id

Type: belongs_to

Related object: L<TMCPE::Schema::IncidentFacilityImpactAnalysis>

=cut

__PACKAGE__->belongs_to(
  "analysis_id",
  "TMCPE::Schema::IncidentFacilityImpactAnalysis",
  { id => "analysis_id" },
);

=head2 incident_section_datas

Type: has_many

Related object: L<TMCPE::Schema::IncidentSectionData>

=cut

__PACKAGE__->has_many(
  "incident_section_datas",
  "TMCPE::Schema::IncidentSectionData",
  { "foreign.section_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:19:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3kK/pJHCHaAouQjJby2Yaw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
