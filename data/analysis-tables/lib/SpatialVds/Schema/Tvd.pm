package SpatialVds::Schema::Tvd;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tvd");
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
  "lanes",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "segment_length",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "version",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "freeway_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "freeway_dir",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "vdstype",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 4,
  },
  "district",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "gid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("tvd_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6Yr2GLSBT5+8JA1YEldXkw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
