package SpatialVds::Schema::VehLengthLookup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VehLengthLookup

=cut

__PACKAGE__->table("veh_length_lookup");

=head1 ACCESSORS

=head2 fwydir

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 timeofday

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 avgvehlength

  data_type: 'real'
  is_nullable: 1

=head2 avgtrucklength

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "fwydir",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "timeofday",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "avgvehlength",
  { data_type => "real", is_nullable => 1 },
  "avgtrucklength",
  { data_type => "real", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("timeofday", "fwydir");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BjIgCMT0KYTTXmYuGge5Bw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
