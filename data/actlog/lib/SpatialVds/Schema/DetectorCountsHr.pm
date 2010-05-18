package SpatialVds::Schema::DetectorCountsHr;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("detector_counts_hr");
__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "obs_day",
  { data_type => "date", default_value => undef, is_nullable => 0, size => 4 },
  "truckcnt",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "vehcnt",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("vds_id", "obs_day");
__PACKAGE__->add_unique_constraint("detector_counts_hr_pkey", ["vds_id", "obs_day"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x2cAe4YSvf0VoBJKT78Myw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
