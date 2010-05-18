package SpatialVds::Schema::VehLengthLookup;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("veh_length_lookup");
__PACKAGE__->add_columns(
  "fwydir",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "timeofday",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "avgvehlength",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "avgtrucklength",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("timeofday", "fwydir");
__PACKAGE__->add_unique_constraint("veh_length_lookup_pkey", ["timeofday", "fwydir"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-18 15:01:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:o+qw1AXJsMkHv6+saTYg+Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
