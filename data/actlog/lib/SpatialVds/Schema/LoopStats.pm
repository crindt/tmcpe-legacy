package SpatialVds::Schema::LoopStats;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("loop_stats");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "estimate_time",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "cv_occ_1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "cv_occ_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "cv_occ_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "cv_volocc_1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "cv_volocc_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "cv_volocc_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_vol_1m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_vol_1r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_vol_mr",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_occ_1m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_occ_1r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_occ_mr",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_volocc_1m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_volocc_1r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_volocc_mr",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "lag1_vol_1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "lag1_vol_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "lag1_vol_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "lag1_occ_1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "lag1_occ_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "lag1_occ_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "mu_vol_1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "mu_vol_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "mu_vol_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "sd_vol_1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "sd_vol_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "sd_vol_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_occ_1m_x_mu_vol_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_occ_1m_x_sd_vol_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "corr_occ_1m_x_lag1_occ_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "cv_volocc_1_x_corr_volocc_1m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "occ_1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "occ_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "occ_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "vol_1",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "vol_m",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "vol_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("loop_stats_pkey", ["id"]);
__PACKAGE__->belongs_to("id", "SpatialVds::Schema::StatsIds", { id => "id" });
__PACKAGE__->has_many(
  "vds_stats",
  "SpatialVds::Schema::VdsStats",
  { "foreign.stats_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-05-10 23:03:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SgDA4EI5WalPx9+UzhrVsg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
