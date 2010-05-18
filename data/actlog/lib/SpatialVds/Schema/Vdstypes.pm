package SpatialVds::Schema::Vdstypes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vdstypes");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 4,
  },
  "description",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("vdstypes_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hZfmuzl66P0RGlvdzRgFCQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
