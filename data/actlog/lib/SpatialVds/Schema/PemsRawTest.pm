package SpatialVds::Schema::PemsRawTest;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("pems_raw_test");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ts",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "n1",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "n2",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "n3",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "n4",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "n5",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "n6",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "n7",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "n8",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "o1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "4,5",
  },
  "o2",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "4,5",
  },
  "o3",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "4,5",
  },
  "o4",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "4,5",
  },
  "o5",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "4,5",
  },
  "o6",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "4,5",
  },
  "o7",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "4,5",
  },
  "o8",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "4,5",
  },
  "s1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,5",
  },
  "s2",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,5",
  },
  "s3",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,5",
  },
  "s4",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,5",
  },
  "s5",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,5",
  },
  "s6",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,5",
  },
  "s7",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,5",
  },
  "s8",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,5",
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-24 21:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:baKpsZv0DF03ik6UWVUCPg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
