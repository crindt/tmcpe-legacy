package TMCPE::ActivityLog::Schema::Icad;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.icad");
__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "logid",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "logtime",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 80,
  },
  "logtype",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 240,
  },
  "location",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 240,
  },
  "area",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 240,
  },
  "thomasbrothers",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 80,
  },
  "tbxy",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 40,
  },
  "d12cad",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 80,
  },
  "d12cadalt",
  {
    data_type => "character varying",
    default_value => "NULL::character varying",
    is_nullable => 1,
    size => 80,
  },
  "log_id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("keyfield");
__PACKAGE__->add_unique_constraint("icad_pkey", ["keyfield"]);
__PACKAGE__->has_many(
  "icad_detail_icads",
  "TMCPE::ActivityLog::Schema::IcadDetail",
  { "foreign.icad" => "self.keyfield" },
);
__PACKAGE__->has_many(
  "icad_detail_icad_ids",
  "TMCPE::ActivityLog::Schema::IcadDetail",
  { "foreign.icad_id" => "self.keyfield" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g5P1joRQCua+DNXVpnDnSA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
