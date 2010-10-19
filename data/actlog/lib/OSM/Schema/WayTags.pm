package OSM::Schema::WayTags;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("way_tags");
__PACKAGE__->add_columns(
  "way_id",
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
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:47:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zBUqpgeZb/udSdtPNDVCSw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
