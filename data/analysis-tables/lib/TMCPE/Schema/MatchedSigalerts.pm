package TMCPE::Schema::MatchedSigalerts;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("matched_sigalerts");
__PACKAGE__->add_columns(
  "cad",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "memo",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 250,
  },
  "stampdate",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "stamptime",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "vdsid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "signame",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "rel_pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "xs",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "pxs",
  {
    data_type => "text[]",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-04-30 14:37:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nXaD99z9CESdl9CSCe9tcg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
