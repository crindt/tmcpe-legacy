package SpatialVds::Schema::WimLengthWeekDayFacility;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimLengthWeekDayFacility

=cut

__PACKAGE__->table("wim_length_week_day_facility");

=head1 ACCESSORS

=head2 site_no

  data_type: 'integer'
  is_nullable: 0

=head2 fwydir

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 datayear

  data_type: 'integer'
  is_nullable: 0

=head2 weekday

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 timeofday

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 totalvehicles

  data_type: 'integer'
  is_nullable: 1

=head2 totalfouraxle

  data_type: 'integer'
  is_nullable: 1

=head2 totalheavytruck

  data_type: 'integer'
  is_nullable: 1

=head2 totalheavyheavy

  data_type: 'integer'
  is_nullable: 1

=head2 totalother

  data_type: 'integer'
  is_nullable: 1

=head2 fouraxlelength

  data_type: 'real'
  is_nullable: 1

=head2 heavytrucklegth

  data_type: 'real'
  is_nullable: 1

=head2 heavyheavylength

  data_type: 'real'
  is_nullable: 1

=head2 otherlength

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", is_nullable => 0 },
  "fwydir",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "datayear",
  { data_type => "integer", is_nullable => 0 },
  "weekday",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "timeofday",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "totalvehicles",
  { data_type => "integer", is_nullable => 1 },
  "totalfouraxle",
  { data_type => "integer", is_nullable => 1 },
  "totalheavytruck",
  { data_type => "integer", is_nullable => 1 },
  "totalheavyheavy",
  { data_type => "integer", is_nullable => 1 },
  "totalother",
  { data_type => "integer", is_nullable => 1 },
  "fouraxlelength",
  { data_type => "real", is_nullable => 1 },
  "heavytrucklegth",
  { data_type => "real", is_nullable => 1 },
  "heavyheavylength",
  { data_type => "real", is_nullable => 1 },
  "otherlength",
  { data_type => "real", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("weekday", "timeofday", "site_no", "fwydir", "datayear");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BELLNLmNJvmasa1WwTEjFg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
