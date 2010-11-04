package SpatialVds::Schema::OctamOnRamps;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamOnRamps

=cut

__PACKAGE__->table("octam_on_ramps");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns("gid", { data_type => "integer", is_nullable => 1 });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7/q9xhC3VRrYEgZxtqfh0A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
