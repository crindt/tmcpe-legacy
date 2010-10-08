package SpatialVds::Schema::Crossings;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("crossings");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('crossings_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "county_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "description",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "freeway_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "freeway_dir",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 2,
  },
  "cal_pm",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 12,
  },
  "abs_pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "crossings_county_id_key",
  [
    "county_id",
    "freeway_id",
    "freeway_dir",
    "description",
    "cal_pm",
  ],
);
__PACKAGE__->add_unique_constraint("crossings_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F7XbW7w5qK41SE5e3/cNLA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
