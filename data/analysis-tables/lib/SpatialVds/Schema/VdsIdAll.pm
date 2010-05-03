package SpatialVds::Schema::VdsIdAll;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_id_all");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "cal_pm",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 12,
  },
  "abs_pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "latitude",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "longitude",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("vds_id_all_pkey", ["id"]);
__PACKAGE__->has_many(
  "vds_freeways",
  "SpatialVds::Schema::VdsFreeway",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_points_4269s",
  "SpatialVds::Schema::VdsPoints4269",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_points_4326s",
  "SpatialVds::Schema::VdsPoints4326",
  { "foreign.vds_id" => "self.id" },
);
__PACKAGE__->has_many(
  "vds_versioneds",
  "SpatialVds::Schema::VdsVersioned",
  { "foreign.id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-03-30 10:50:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3hLr5Sn1YX8yfCX/DgEVnQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
