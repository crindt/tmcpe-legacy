package OSM::Schema::Users;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::Users

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LS/3sXIeoWrx2DLEzZvHpQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
