package SpatialVds::Schema::PemsRaw;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("pems_raw");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ts",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "n1",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "n2",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "n3",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "n4",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "n5",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "n6",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "n7",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "n8",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
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
  "s1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "s2",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "s3",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "s4",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "s5",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "s6",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "s7",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "s8",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YGiZk4VH4DaFyRdplQDqKQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
