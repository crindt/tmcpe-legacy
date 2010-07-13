package SpatialVds::Schema::PemsRaw5minuteAggregates;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("pems_raw_5minute_aggregates");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "tod",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "dow",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "mon",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "intervals",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "nsum",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "oave",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "nlanes",
  {
    data_type => "bigint[]",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "olanes",
  {
    data_type => "numeric[]",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kn2tNGpeY98QcI+ITUxi/w


# You can replace this text with custom content, and it will be preserved on regeneration
1;