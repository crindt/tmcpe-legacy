package OSM::Schema::NodeTags;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::NodeTags

=cut

__PACKAGE__->table("node_tags");

=head1 ACCESSORS

=head2 node_id

  data_type: 'bigint'
  is_nullable: 0

=head2 k

  data_type: 'text'
  is_nullable: 0

=head2 v

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "node_id",
  { data_type => "bigint", is_nullable => 0 },
  "k",
  { data_type => "text", is_nullable => 0 },
  "v",
  { data_type => "text", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:omQ/+xGmrTgfc8qME/u+KA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
