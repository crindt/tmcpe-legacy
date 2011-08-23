package SpatialVds::Schema::OctamTazAll2000;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamTazAll2000

=cut

__PACKAGE__->table("octam_taz_all_2000");

=head1 ACCESSORS

=head2 taz_id

  data_type: 'integer'
  is_nullable: 1

=head2 pop_tot

  data_type: 'integer'
  is_nullable: 1

=head2 pop_in_hh

  data_type: 'integer'
  is_nullable: 1

=head2 pop_emp

  data_type: 'integer'
  is_nullable: 1

=head2 pop_grp

  data_type: 'integer'
  is_nullable: 1

=head2 hh_sf

  data_type: 'integer'
  is_nullable: 1

=head2 hh_mf

  data_type: 'integer'
  is_nullable: 1

=head2 hh_tot

  data_type: 'integer'
  is_nullable: 1

=head2 hh_size

  data_type: 'double precision'
  is_nullable: 1

=head2 emp_retail

  data_type: 'integer'
  is_nullable: 1

=head2 emp_serv

  data_type: 'integer'
  is_nullable: 1

=head2 emp_basic

  data_type: 'integer'
  is_nullable: 1

=head2 emp_tot

  data_type: 'integer'
  is_nullable: 1

=head2 income

  data_type: 'integer'
  is_nullable: 1

=head2 sch_enroll

  data_type: 'integer'
  is_nullable: 1

=head2 univ_enroll

  data_type: 'integer'
  is_nullable: 1

=head2 area

  data_type: 'integer'
  is_nullable: 1

=head2 autos

  data_type: 'integer'
  is_nullable: 1

=head2 x_centroid

  data_type: 'integer'
  is_nullable: 1

=head2 y_centroid

  data_type: 'integer'
  is_nullable: 1

=head2 county

  data_type: 'smallint'
  is_nullable: 1

=head2 the_geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "taz_id",
  { data_type => "integer", is_nullable => 1 },
  "pop_tot",
  { data_type => "integer", is_nullable => 1 },
  "pop_in_hh",
  { data_type => "integer", is_nullable => 1 },
  "pop_emp",
  { data_type => "integer", is_nullable => 1 },
  "pop_grp",
  { data_type => "integer", is_nullable => 1 },
  "hh_sf",
  { data_type => "integer", is_nullable => 1 },
  "hh_mf",
  { data_type => "integer", is_nullable => 1 },
  "hh_tot",
  { data_type => "integer", is_nullable => 1 },
  "hh_size",
  { data_type => "double precision", is_nullable => 1 },
  "emp_retail",
  { data_type => "integer", is_nullable => 1 },
  "emp_serv",
  { data_type => "integer", is_nullable => 1 },
  "emp_basic",
  { data_type => "integer", is_nullable => 1 },
  "emp_tot",
  { data_type => "integer", is_nullable => 1 },
  "income",
  { data_type => "integer", is_nullable => 1 },
  "sch_enroll",
  { data_type => "integer", is_nullable => 1 },
  "univ_enroll",
  { data_type => "integer", is_nullable => 1 },
  "area",
  { data_type => "integer", is_nullable => 1 },
  "autos",
  { data_type => "integer", is_nullable => 1 },
  "x_centroid",
  { data_type => "integer", is_nullable => 1 },
  "y_centroid",
  { data_type => "integer", is_nullable => 1 },
  "county",
  { data_type => "smallint", is_nullable => 1 },
  "the_geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+WJBZdo6+9KT3OCtTI/2mQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
