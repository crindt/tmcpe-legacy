package SpatialVds::Schema::TestbedFacilities;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("testbed_facilities");
__PACKAGE__->add_columns(
  "tfid",
  {
    data_type => "integer",
    default_value => "nextval('testbed_facilities_tfid_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "net",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ref",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "dir",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "rteid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("tfid");
__PACKAGE__->add_unique_constraint("testbed_facilities_pkey", ["tfid"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-27 17:06:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zcsg8GJ9O5IGqW3/3m3/7A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
