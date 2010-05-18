package TMCPE::ActivityLog::Schema::IcadDetail;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.icad_detail");
__PACKAGE__->add_columns(
  "keyfield",
  {
    data_type => "integer",
    default_value => "nextval('actlog.icad_detail_keyfield_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "icad",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "stamp",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "detail",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 1024,
  },
  "icad_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("keyfield");
__PACKAGE__->add_unique_constraint("icad_detail_pkey", ["keyfield"]);
__PACKAGE__->belongs_to(
  "icad",
  "TMCPE::ActivityLog::Schema::Icad",
  { keyfield => "icad" },
);
__PACKAGE__->belongs_to(
  "icad_id",
  "TMCPE::ActivityLog::Schema::Icad",
  { keyfield => "icad_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:02:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gUKoUtH/lSmPiOT9w5oQnw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
