package SpatialVds::Schema::DesignFwyVehTime;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::DesignFwyVehTime

=cut

__PACKAGE__->table("design_fwy_veh_time");

=head1 ACCESSORS

=head2 obs_no

  data_type: 'integer'
  is_nullable: 1

=head2 site_no

  data_type: 'integer'
  is_nullable: 1

=head2 district_id

  data_type: 'integer'
  is_nullable: 1

=head2 fwydir

  data_type: 'text'
  is_nullable: 1

=head2 dow

  data_type: 'text'
  is_nullable: 1

=head2 timeofday

  data_type: 'text'
  is_nullable: 1

=head2 fouraxle

  data_type: 'integer'
  is_nullable: 1

=head2 heavytruck

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "obs_no",
  { data_type => "integer", is_nullable => 1 },
  "site_no",
  { data_type => "integer", is_nullable => 1 },
  "district_id",
  { data_type => "integer", is_nullable => 1 },
  "fwydir",
  { data_type => "text", is_nullable => 1 },
  "dow",
  { data_type => "text", is_nullable => 1 },
  "timeofday",
  { data_type => "text", is_nullable => 1 },
  "fouraxle",
  { data_type => "integer", is_nullable => 1 },
  "heavytruck",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SoGtP1cjGF++/A0vcue0KA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
