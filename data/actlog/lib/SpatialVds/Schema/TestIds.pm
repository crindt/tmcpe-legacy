package SpatialVds::Schema::TestIds;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::TestIds

=cut

__PACKAGE__->table("test_ids");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'test_ids_gid_seq'

=head2 dummy

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "test_ids_gid_seq",
  },
  "dummy",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D4gtjlAwWaFrqMTOqA35eg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
