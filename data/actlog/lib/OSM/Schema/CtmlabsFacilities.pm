package OSM::Schema::CtmlabsFacilities;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::CtmlabsFacilities

=cut

__PACKAGE__->table("ctmlabs_facilities");

=head1 ACCESSORS

=head2 tfid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'ctmlabs_facilities_tfid_seq'

=head2 net

  data_type: 'text'
  is_nullable: 1

=head2 ref

  data_type: 'text'
  is_nullable: 1

=head2 dir

  data_type: 'text'
  is_nullable: 1

=head2 rteid

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "tfid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "ctmlabs_facilities_tfid_seq",
  },
  "net",
  { data_type => "text", is_nullable => 1 },
  "ref",
  { data_type => "text", is_nullable => 1 },
  "dir",
  { data_type => "text", is_nullable => 1 },
  "rteid",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("tfid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AEW+kJqX1XK5aXBDWjOaig


# You can replace this text with custom content, and it will be preserved on regeneration
1;
