package SpatialVds::Schema::Districts;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("districts");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('districts_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("districts_pkey", ["id"]);
__PACKAGE__->has_many(
  "wim_districts",
  "SpatialVds::Schema::WimDistrict",
  { "foreign.district_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-07 16:07:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1I9zvppzqh85+jZvt6cqKw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
