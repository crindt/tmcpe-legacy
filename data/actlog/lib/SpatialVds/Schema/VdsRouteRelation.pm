package SpatialVds::Schema::VdsRouteRelation;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_route_relation");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "adj_pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "rel",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "vdssnap",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "dist",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "line",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "vds_sequence_id",
  {
    data_type => "integer",
    default_value => "nextval('vds_route_relation_vds_sequence_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("vds_route_relation_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j9wNecuaIbQROHZK9/3oiA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
