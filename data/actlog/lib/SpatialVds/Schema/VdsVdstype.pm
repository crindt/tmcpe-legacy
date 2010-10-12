package SpatialVds::Schema::VdsVdstype;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("vds_vdstype");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "type_id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 4,
  },
);
__PACKAGE__->set_primary_key("vds_id");
__PACKAGE__->add_unique_constraint("vds_vdstype_pkey", ["vds_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GNAf1hKZBpyz0/ZjSs/AHw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
