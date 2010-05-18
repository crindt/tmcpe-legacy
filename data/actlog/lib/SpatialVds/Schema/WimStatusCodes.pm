package SpatialVds::Schema::WimStatusCodes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_status_codes");
__PACKAGE__->add_columns(
  "status",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "description",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("status");
__PACKAGE__->add_unique_constraint("wim_status_codes_pkey", ["status"]);
__PACKAGE__->has_many(
  "wim_status_weight_statuses",
  "SpatialVds::Schema::WimStatus",
  { "foreign.weight_status" => "self.status" },
);
__PACKAGE__->has_many(
  "wim_status_class_statuses",
  "SpatialVds::Schema::WimStatus",
  { "foreign.class_status" => "self.status" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sk3QvTo0Pm9ZVYUgz79VFg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
