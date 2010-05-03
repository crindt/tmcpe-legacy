package SpatialVds::Schema::Timestamps;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("timestamps");
__PACKAGE__->add_columns(
  "ts",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "fivemin",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "dow",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
);
__PACKAGE__->set_primary_key("ts");
__PACKAGE__->add_unique_constraint("timestamps_pkey", ["ts"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dN2eX4iQ0yvAzCF1VVXejA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
