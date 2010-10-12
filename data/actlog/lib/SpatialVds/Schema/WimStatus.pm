package SpatialVds::Schema::WimStatus;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("wim_status");
__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ts",
  { data_type => "date", default_value => undef, is_nullable => 0, size => 4 },
  "class_status",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "class_notes",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "weight_status",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "weight_notes",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("site_no", "ts");
__PACKAGE__->add_unique_constraint("wim_status_pkey", ["site_no", "ts"]);
__PACKAGE__->belongs_to(
  "site_no",
  "SpatialVds::Schema::WimStations",
  { site_no => "site_no" },
);
__PACKAGE__->belongs_to(
  "weight_status",
  "SpatialVds::Schema::WimStatusCodes",
  { status => "weight_status" },
);
__PACKAGE__->belongs_to(
  "class_status",
  "SpatialVds::Schema::WimStatusCodes",
  { status => "class_status" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+E2XdDZZMkkQbb3IrRJ1RQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
