package TBMAP::Schema::VdsSegmentGeometry;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tbmap.vds_segment_geometry");
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
  "raw_seggeom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "seggeom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("vds_segment_geometry_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-18 14:46:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QXS192+BAsAXWTZbplGX+w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
