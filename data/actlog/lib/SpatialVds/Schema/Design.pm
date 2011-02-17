package SpatialVds::Schema::Design;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Design

=cut

__PACKAGE__->table("design");

=head1 ACCESSORS

=head2 trial_id

  data_type: 'integer'
  is_nullable: 1

=head2 obs_id

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "trial_id",
  { data_type => "integer", is_nullable => 1 },
  "obs_id",
  { data_type => "double precision", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vl+NsT8M14vTNRkKA/jBQQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
