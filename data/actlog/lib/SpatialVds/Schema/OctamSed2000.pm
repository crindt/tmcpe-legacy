package SpatialVds::Schema::OctamSed2000;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_sed_2000");
__PACKAGE__->add_columns(
  "taz_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "pop_tot",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "pop_in_hh",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "pop_emp",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "pop_grp",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "hh_sf",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "hh_mf",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "hh_tot",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "hh_size",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "emp_retail",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "emp_serv",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "emp_basic",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "emp_tot",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "income",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sch_enroll",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "univ_enroll",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "area",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "autos",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "x_centroid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "y_centroid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "county",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
);
__PACKAGE__->set_primary_key("taz_id");
__PACKAGE__->add_unique_constraint("octam_sed_2000_pkey", ["taz_id"]);
__PACKAGE__->belongs_to(
  "taz_id",
  "SpatialVds::Schema::OctamTaz",
  { taz_id => "taz_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 23:55:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OVS1kO43mcrbSiRipAqFwA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
