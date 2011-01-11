package SpatialVds::Schema::Crossings;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Crossings

=cut

__PACKAGE__->table("crossings");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'crossings_id_seq'

=head2 county_id

  data_type: 'integer'
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 freeway_id

  data_type: 'integer'
  is_nullable: 0

=head2 freeway_dir

  data_type: 'varchar'
  is_nullable: 0
  size: 2

=head2 cal_pm

  data_type: 'varchar'
  is_nullable: 0
  size: 12

=head2 abs_pm

  data_type: 'double precision'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "crossings_id_seq",
  },
  "county_id",
  { data_type => "integer", is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "freeway_id",
  { data_type => "integer", is_nullable => 0 },
  "freeway_dir",
  { data_type => "varchar", is_nullable => 0, size => 2 },
  "cal_pm",
  { data_type => "varchar", is_nullable => 0, size => 12 },
  "abs_pm",
  { data_type => "double precision", is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:J/qEL2UsQISzJ0WqxjzZ1w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
