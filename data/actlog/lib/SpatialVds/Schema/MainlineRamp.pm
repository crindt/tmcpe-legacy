package SpatialVds::Schema::MainlineRamp;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("mainline_ramp");
__PACKAGE__->add_columns(
  "ml_vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "r_vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "distance",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("ml_vds_id", "r_vds_id");
__PACKAGE__->add_unique_constraint("mainline_ramp_pkey", ["ml_vds_id", "r_vds_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GDCKkoGB8lA60NCS20/f2w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
