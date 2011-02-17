package OSM::Schema::Routes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::Routes

=cut

__PACKAGE__->table("routes");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_nullable: 1

=head2 version

  data_type: 'integer'
  is_nullable: 1

=head2 user_id

  data_type: 'integer'
  is_nullable: 1

=head2 tstamp

  data_type: 'timestamp'
  is_nullable: 1

=head2 changeset_id

  data_type: 'bigint'
  is_nullable: 1

=head2 net

  data_type: 'text'
  is_nullable: 1

=head2 ref

  data_type: 'text'
  is_nullable: 1

=head2 dir

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", is_nullable => 1 },
  "version",
  { data_type => "integer", is_nullable => 1 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
  "tstamp",
  { data_type => "timestamp", is_nullable => 1 },
  "changeset_id",
  { data_type => "bigint", is_nullable => 1 },
  "net",
  { data_type => "text", is_nullable => 1 },
  "ref",
  { data_type => "text", is_nullable => 1 },
  "dir",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jKa8V7xMOU+B9JCBsc85fg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
