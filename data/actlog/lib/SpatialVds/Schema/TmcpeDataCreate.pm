package SpatialVds::Schema::TmcpeDataCreate;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tmcpe_data_create");
__PACKAGE__->add_columns(
  "stamp",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "vdsid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "days_in_avg",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "avg_samples",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "a_pct_obs",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "a_vol",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "a_occ",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "a_spd",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "sd_vol",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "sd_occ",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "sd_spd",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TSZd10qn1j05+D8145uJrg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
