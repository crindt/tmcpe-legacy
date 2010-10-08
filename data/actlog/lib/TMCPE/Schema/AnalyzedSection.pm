package TMCPE::Schema::AnalyzedSection;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tmcpe.analyzed_section");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('tmcpe.analyzed_section_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "analysis_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "section_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "version",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("analyzed_section_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "analysis_id",
  "TMCPE::Schema::IncidentFacilityImpactAnalysis",
  { id => "analysis_id" },
);
__PACKAGE__->has_many(
  "incident_section_datas",
  "TMCPE::Schema::IncidentSectionData",
  { "foreign.section_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tVbMQn/k5PJzFGGBviyoKQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
