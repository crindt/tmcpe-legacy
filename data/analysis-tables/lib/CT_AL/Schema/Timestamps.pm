package CT_AL::Schema::Timestamps;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("timestamps");
__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ts",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("keyfield");
__PACKAGE__->add_unique_constraint("timestamps_pkey", ["keyfield"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-25 12:13:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MpsIuwYPLUy3f17883x/Qg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
