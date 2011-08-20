package TMCPE::Schema::IncidentSectionData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::Schema::IncidentSectionData

=cut

__PACKAGE__->table("tmcpe.incident_section_data");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tmcpe.incident_section_data_id_seq'

=head2 occ_avg

  data_type: 'real'
  is_nullable: 1

=head2 vol_avg

  data_type: 'real'
  is_nullable: 1

=head2 pct_obs_avg

  data_type: 'real'
  is_nullable: 1

=head2 section_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 tmcpe_delay

  data_type: 'real'
  is_nullable: 1

=head2 d12_delay

  data_type: 'real'
  is_nullable: 1

=head2 vol

  data_type: 'integer'
  is_nullable: 1

=head2 spd_avg

  data_type: 'real'
  is_nullable: 1

=head2 fivemin

  data_type: 'timestamp'
  is_nullable: 0

=head2 days_in_avg

  data_type: 'integer'
  is_nullable: 1

=head2 spd

  data_type: 'real'
  is_nullable: 1

=head2 incident_flag

  data_type: 'real'
  is_nullable: 1

=head2 p_j_m

  data_type: 'real'
  is_nullable: 1

=head2 occ

  data_type: 'real'
  is_nullable: 1

=head2 spd_std

  data_type: 'real'
  is_nullable: 1

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
    sequence          => "tmcpe.incident_section_data_id_seq",
  },
  "occ_avg",
  { data_type => "real", is_nullable => 1 },
  "vol_avg",
  { data_type => "real", is_nullable => 1 },
  "pct_obs_avg",
  { data_type => "real", is_nullable => 1 },
  "section_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "tmcpe_delay",
  { data_type => "real", is_nullable => 1 },
  "d12_delay",
  { data_type => "real", is_nullable => 1 },
  "vol",
  { data_type => "integer", is_nullable => 1 },
  "spd_avg",
  { data_type => "real", is_nullable => 1 },
  "fivemin",
  { data_type => "timestamp", is_nullable => 0 },
  "days_in_avg",
  { data_type => "integer", is_nullable => 1 },
  "spd",
  { data_type => "real", is_nullable => 1 },
  "incident_flag",
  { data_type => "real", is_nullable => 1 },
  "p_j_m",
  { data_type => "real", is_nullable => 1 },
  "occ",
  { data_type => "real", is_nullable => 1 },
  "spd_std",
  { data_type => "real", is_nullable => 1 },
  "version",
  { data_type => "bigint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 section_id

Type: belongs_to

Related object: L<TMCPE::Schema::AnalyzedSection>

=cut

__PACKAGE__->belongs_to(
  "section_id",
  "TMCPE::Schema::AnalyzedSection",
  { id => "section_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hnhzNW7e/7gqyua+SUnpgg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
