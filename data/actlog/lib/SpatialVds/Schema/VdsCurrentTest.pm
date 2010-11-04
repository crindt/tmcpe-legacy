package SpatialVds::Schema::VdsCurrentTest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsCurrentTest

=cut

__PACKAGE__->table("vds_current_test");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 version

  data_type: 'date'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "version",
  { data_type => "date", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id", "version");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vE7XMMZpFhwBT0xz5iAP2g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
