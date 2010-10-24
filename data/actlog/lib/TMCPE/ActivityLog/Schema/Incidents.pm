package TMCPE::ActivityLog::Schema::Incidents;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.incidents");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('actlog.incidents_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "cad",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "start_time",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "first_call",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sigalert_begin",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sigalert_end",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "location_vdsid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "event_type",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 80,
  },
  "location_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("incidents_cad_key", ["cad"]);
__PACKAGE__->add_unique_constraint("incidents_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "first_call",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "first_call" },
);
__PACKAGE__->belongs_to(
  "sigalert_end",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "sigalert_end" },
);
__PACKAGE__->belongs_to(
  "sigalert_begin",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "sigalert_begin" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SDQTH9ItfYWJNor2xPJHXw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
