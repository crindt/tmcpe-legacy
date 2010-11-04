package OSM::Schema::RelationMembers;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::RelationMembers

=cut

__PACKAGE__->table("relation_members");

=head1 ACCESSORS

=head2 relation_id

  data_type: 'bigint'
  is_nullable: 0

=head2 member_id

  data_type: 'bigint'
  is_nullable: 0

=head2 member_type

  data_type: 'char'
  is_nullable: 0
  size: 1

=head2 member_role

  data_type: 'text'
  is_nullable: 0

=head2 sequence_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "relation_id",
  { data_type => "bigint", is_nullable => 0 },
  "member_id",
  { data_type => "bigint", is_nullable => 0 },
  "member_type",
  { data_type => "char", is_nullable => 0, size => 1 },
  "member_role",
  { data_type => "text", is_nullable => 0 },
  "sequence_id",
  { data_type => "integer", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FZ7mXOEkiAZq9tD0kv0jsg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
