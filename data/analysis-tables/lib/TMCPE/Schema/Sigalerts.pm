package TMCPE::Schema::Sigalerts;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("sigalerts");
__PACKAGE__->add_columns(
  "cad",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-04-30 14:37:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BxzJCEwWZxbHBsre0QSxRA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
