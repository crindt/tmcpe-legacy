package OSM::Schema::Ways;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("ways");
__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "version",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "tstamp",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "changeset_id",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "bbox",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "linestring",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_ways", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HgZunbwQpV7la1lwjDfckQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
