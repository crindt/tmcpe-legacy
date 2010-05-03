package SpatialVds::Schema::Counties;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("counties");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('counties_id_seq'::regclass)",
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
__PACKAGE__->add_unique_constraint("counties_pkey", ["id"]);
__PACKAGE__->has_many(
  "wim_counties",
  "SpatialVds::Schema::WimCounty",
  { "foreign.county_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lGkmmuIrSrqu9PMoa48bbw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
