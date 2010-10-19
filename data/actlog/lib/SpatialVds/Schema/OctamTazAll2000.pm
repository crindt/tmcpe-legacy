package SpatialVds::Schema::OctamTazAll2000;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_taz_all_2000");
__PACKAGE__->add_columns(
  "taz_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
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
  "the_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:46:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DWE7/QjyiaePs7oQNmJsNA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
