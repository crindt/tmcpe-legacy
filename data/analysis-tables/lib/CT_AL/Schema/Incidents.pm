package CT_AL::Schema::Incidents;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("actlog.incidents");
__PACKAGE__->add_columns(
  "cad",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "start_time",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-25 12:13:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GMM/j/NVxDUt664z5jui/Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
