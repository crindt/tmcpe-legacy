package TMCPE::ActivityLog::Schema::FullIncidents;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.full_incidents");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
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
  "best_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:00:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ife3gZrMEN5mLcpZtGH7NA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
