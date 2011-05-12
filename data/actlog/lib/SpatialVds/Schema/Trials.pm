package SpatialVds::Schema::Trials;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Trials

=cut

__PACKAGE__->table("trials");

=head1 ACCESSORS

=head2 trial_id

  data_type: 'integer'
  is_nullable: 1

=head2 avg_total_axle_spacing

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "trial_id",
  { data_type => "integer", is_nullable => 1 },
  "avg_total_axle_spacing",
  { data_type => "double precision", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:olauyTGjBbi2EWIbXPoCsg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
