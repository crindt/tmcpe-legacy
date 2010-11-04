package SpatialVds::Schema::VdsSed2000OrAlt;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsSed2000OrAlt

=cut

__PACKAGE__->table("vds_sed_2000_or_alt");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 freeway_dir

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 type_id

  data_type: 'varchar'
  is_nullable: 1
  size: 4

=head2 district_id

  data_type: 'integer'
  is_nullable: 1

=head2 pop_tot

  data_type: 'double precision'
  is_nullable: 1

=head2 pop_in_hh

  data_type: 'double precision'
  is_nullable: 1

=head2 pop_emp

  data_type: 'double precision'
  is_nullable: 1

=head2 pop_grp

  data_type: 'double precision'
  is_nullable: 1

=head2 hh_sf

  data_type: 'double precision'
  is_nullable: 1

=head2 hh_mf

  data_type: 'double precision'
  is_nullable: 1

=head2 hh_tot

  data_type: 'double precision'
  is_nullable: 1

=head2 hh_size

  data_type: 'double precision'
  is_nullable: 1

=head2 emp_retail

  data_type: 'double precision'
  is_nullable: 1

=head2 emp_serv

  data_type: 'double precision'
  is_nullable: 1

=head2 emp_basic

  data_type: 'double precision'
  is_nullable: 1

=head2 emp_tot

  data_type: 'double precision'
  is_nullable: 1

=head2 income

  data_type: 'double precision'
  is_nullable: 1

=head2 sch_enroll

  data_type: 'double precision'
  is_nullable: 1

=head2 univ_enroll

  data_type: 'double precision'
  is_nullable: 1

=head2 area

  data_type: 'double precision'
  is_nullable: 1

=head2 autos

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "freeway_dir",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "type_id",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "district_id",
  { data_type => "integer", is_nullable => 1 },
  "pop_tot",
  { data_type => "double precision", is_nullable => 1 },
  "pop_in_hh",
  { data_type => "double precision", is_nullable => 1 },
  "pop_emp",
  { data_type => "double precision", is_nullable => 1 },
  "pop_grp",
  { data_type => "double precision", is_nullable => 1 },
  "hh_sf",
  { data_type => "double precision", is_nullable => 1 },
  "hh_mf",
  { data_type => "double precision", is_nullable => 1 },
  "hh_tot",
  { data_type => "double precision", is_nullable => 1 },
  "hh_size",
  { data_type => "double precision", is_nullable => 1 },
  "emp_retail",
  { data_type => "double precision", is_nullable => 1 },
  "emp_serv",
  { data_type => "double precision", is_nullable => 1 },
  "emp_basic",
  { data_type => "double precision", is_nullable => 1 },
  "emp_tot",
  { data_type => "double precision", is_nullable => 1 },
  "income",
  { data_type => "double precision", is_nullable => 1 },
  "sch_enroll",
  { data_type => "double precision", is_nullable => 1 },
  "univ_enroll",
  { data_type => "double precision", is_nullable => 1 },
  "area",
  { data_type => "double precision", is_nullable => 1 },
  "autos",
  { data_type => "double precision", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9Payj05oHO6GK9w6cuha7g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
