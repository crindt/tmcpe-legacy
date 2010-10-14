package OSM::Schema::RelationTags;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("relation_tags");
__PACKAGE__->add_columns(
  "relation_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "k",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "v",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tnsXHVty+bFnEvbRAAlz6A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
