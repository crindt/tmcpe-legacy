package SpatialVds::Schema::PemsRaw5min;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("pems_raw_5min");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ts5min",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "n1",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "n2",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "n3",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "n4",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "n5",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "n6",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "n7",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "n8",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "ntot",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "o1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "o2",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "o3",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "o4",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "o5",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "o6",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "o7",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "o8",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NR8fBFhicKtqlehckBYExg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
