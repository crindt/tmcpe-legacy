package OSM::Schema::RelationTags;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::RelationTags

=cut

__PACKAGE__->table("relation_tags");

=head1 ACCESSORS

=head2 relation_id

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
  "relation_id",
  { data_type => "bigint", is_nullable => 0 },
  "k",
  { data_type => "text", is_nullable => 0 },
  "v",
  { data_type => "text", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MW6V9N/VGstlLYQanvWi2A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
