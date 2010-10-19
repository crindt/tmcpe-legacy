package OSM::Schema::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:47:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ws4Gf2mN2e4Mxy/LcOv8SQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
