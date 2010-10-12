package TMCPE::Schema::SigalertLocationsGrailsTable;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tmcpe.sigalert_locations_grails_table");
__PACKAGE__->add_columns(
  "cad",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "stamptime",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "stampdate",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "memo",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "location",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "analyses_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "vdsid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("cad");
__PACKAGE__->add_unique_constraint("sigalert_locations_grails_table_pkey", ["cad"]);
__PACKAGE__->belongs_to(
  "analyses_id",
  "TMCPE::Schema::IncidentImpactAnalysis",
  { id => "analyses_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:54:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1GwVCkoTCikzxFL0t6B1Gg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
