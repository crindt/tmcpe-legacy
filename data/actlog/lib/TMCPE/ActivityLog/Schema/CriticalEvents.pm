package TMCPE::ActivityLog::Schema::CriticalEvents;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.critical_events");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('actlog.critical_events_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "log_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "event_type",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "detail",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("critical_events_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "log_id",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "log_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gUpCP1rQye6tD7X/+WizUA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
