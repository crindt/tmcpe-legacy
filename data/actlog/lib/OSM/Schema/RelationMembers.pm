package OSM::Schema::RelationMembers;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("relation_members");
__PACKAGE__->add_columns(
  "relation_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "member_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "member_type",
  {
    data_type => "character",
    default_value => undef,
    is_nullable => 0,
    size => 1,
  },
  "member_role",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "sequence_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:47:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jLIIGRSxkBdEKH4mkgrQbw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
