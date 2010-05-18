package SpatialVds::Schema::OctamGeom2230;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_geom_2230");
__PACKAGE__->add_columns(
  "taz_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "geom_2230",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("taz_id");
__PACKAGE__->add_unique_constraint("octam_geom_2230_pkey", ["taz_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HxKHDxlw4KS6Fx+wUiMdkA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
