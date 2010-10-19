package SpatialVds::Schema::VdsComplete;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_complete");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "freeway_dir",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "lanes",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "cal_pm",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
  "abs_pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "latitude",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "longitude",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "version",
  { data_type => "date", default_value => undef, is_nullable => 0, size => 4 },
  "length",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id", "version");
__PACKAGE__->add_unique_constraint("vds_complete_pkey", ["id", "version"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:46:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l2YCd7SYNDzc1s4fVTy4wA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
