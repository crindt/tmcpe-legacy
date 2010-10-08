package TMCPE::Schema::IncidentSectionData;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tmcpe.incident_section_data");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('tmcpe.incident_section_data_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "occ_avg",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vol_avg",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "pct_obs_avg",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "section_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "tmcpe_delay",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "d12_delay",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vol",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "spd_avg",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "fivemin",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "days_in_avg",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "spd",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "incident_flag",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "p_j_m",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "occ",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "spd_std",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "version",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("incident_section_data_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "section_id",
  "TMCPE::Schema::AnalyzedSection",
  { id => "section_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YyBINCUSWMsy22UXsJOREQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
