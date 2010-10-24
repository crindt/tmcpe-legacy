package OSM::Schema::Routes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("routes");
__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "version",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "tstamp",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "changeset_id",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "net",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ref",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "dir",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-23 11:03:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:16FkQwP7SrpNlsdyBwyNKg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
