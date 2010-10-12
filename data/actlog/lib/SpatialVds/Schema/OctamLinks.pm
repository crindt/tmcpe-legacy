package SpatialVds::Schema::OctamLinks;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_links");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('link_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "frnode",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "tonode",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "type",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "spd",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("octamlinks_pkey", ["id"]);
__PACKAGE__->belongs_to("tonode", "SpatialVds::Schema::OctamNodes", { id => "tonode" });
__PACKAGE__->belongs_to("frnode", "SpatialVds::Schema::OctamNodes", { id => "frnode" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-11 14:56:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:28YTp4jmqzo2SULkTDgMgg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
