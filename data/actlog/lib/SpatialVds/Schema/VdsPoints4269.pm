package SpatialVds::Schema::VdsPoints4269;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_points_4269");
__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("vds_id");
__PACKAGE__->add_unique_constraint("vds_points_4269_pkey", ["vds_id"]);
__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::VdsIdAll", { id => "vds_id" });
__PACKAGE__->belongs_to("gid", "SpatialVds::Schema::GeomPoints4269", { gid => "gid" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-24 21:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:r/cyNQeJUOzCp42UJpkqMQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
