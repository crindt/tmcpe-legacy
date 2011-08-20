package SpatialVds::Schema::LoopStats;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::LoopStats

=cut

__PACKAGE__->table("loop_stats");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 estimate_time

  data_type: 'timestamp'
  is_nullable: 0

=head2 cv_occ_1

  data_type: 'numeric'
  is_nullable: 0

=head2 cv_occ_m

  data_type: 'numeric'
  is_nullable: 0

=head2 cv_occ_r

  data_type: 'numeric'
  is_nullable: 0

=head2 cv_volocc_1

  data_type: 'numeric'
  is_nullable: 0

=head2 cv_volocc_m

  data_type: 'numeric'
  is_nullable: 0

=head2 cv_volocc_r

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_vol_1m

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_vol_1r

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_vol_mr

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_occ_1m

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_occ_1r

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_occ_mr

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_volocc_1m

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_volocc_1r

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_volocc_mr

  data_type: 'numeric'
  is_nullable: 0

=head2 lag1_vol_1

  data_type: 'numeric'
  is_nullable: 0

=head2 lag1_vol_m

  data_type: 'numeric'
  is_nullable: 0

=head2 lag1_vol_r

  data_type: 'numeric'
  is_nullable: 0

=head2 lag1_occ_1

  data_type: 'numeric'
  is_nullable: 0

=head2 lag1_occ_m

  data_type: 'numeric'
  is_nullable: 0

=head2 lag1_occ_r

  data_type: 'numeric'
  is_nullable: 0

=head2 mu_vol_1

  data_type: 'numeric'
  is_nullable: 0

=head2 mu_vol_m

  data_type: 'numeric'
  is_nullable: 0

=head2 mu_vol_r

  data_type: 'numeric'
  is_nullable: 0

=head2 sd_vol_1

  data_type: 'numeric'
  is_nullable: 0

=head2 sd_vol_m

  data_type: 'numeric'
  is_nullable: 0

=head2 sd_vol_r

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_occ_1m_x_mu_vol_m

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_occ_1m_x_sd_vol_r

  data_type: 'numeric'
  is_nullable: 0

=head2 corr_occ_1m_x_lag1_occ_r

  data_type: 'numeric'
  is_nullable: 0

=head2 cv_volocc_1_x_corr_volocc_1m

  data_type: 'numeric'
  is_nullable: 0

=head2 occ_1

  data_type: 'numeric'
  is_nullable: 1

=head2 occ_m

  data_type: 'numeric'
  is_nullable: 1

=head2 occ_r

  data_type: 'numeric'
  is_nullable: 1

=head2 vol_1

  data_type: 'numeric'
  is_nullable: 1

=head2 vol_m

  data_type: 'numeric'
  is_nullable: 1

=head2 vol_r

  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "estimate_time",
  { data_type => "timestamp", is_nullable => 0 },
  "cv_occ_1",
  { data_type => "numeric", is_nullable => 0 },
  "cv_occ_m",
  { data_type => "numeric", is_nullable => 0 },
  "cv_occ_r",
  { data_type => "numeric", is_nullable => 0 },
  "cv_volocc_1",
  { data_type => "numeric", is_nullable => 0 },
  "cv_volocc_m",
  { data_type => "numeric", is_nullable => 0 },
  "cv_volocc_r",
  { data_type => "numeric", is_nullable => 0 },
  "corr_vol_1m",
  { data_type => "numeric", is_nullable => 0 },
  "corr_vol_1r",
  { data_type => "numeric", is_nullable => 0 },
  "corr_vol_mr",
  { data_type => "numeric", is_nullable => 0 },
  "corr_occ_1m",
  { data_type => "numeric", is_nullable => 0 },
  "corr_occ_1r",
  { data_type => "numeric", is_nullable => 0 },
  "corr_occ_mr",
  { data_type => "numeric", is_nullable => 0 },
  "corr_volocc_1m",
  { data_type => "numeric", is_nullable => 0 },
  "corr_volocc_1r",
  { data_type => "numeric", is_nullable => 0 },
  "corr_volocc_mr",
  { data_type => "numeric", is_nullable => 0 },
  "lag1_vol_1",
  { data_type => "numeric", is_nullable => 0 },
  "lag1_vol_m",
  { data_type => "numeric", is_nullable => 0 },
  "lag1_vol_r",
  { data_type => "numeric", is_nullable => 0 },
  "lag1_occ_1",
  { data_type => "numeric", is_nullable => 0 },
  "lag1_occ_m",
  { data_type => "numeric", is_nullable => 0 },
  "lag1_occ_r",
  { data_type => "numeric", is_nullable => 0 },
  "mu_vol_1",
  { data_type => "numeric", is_nullable => 0 },
  "mu_vol_m",
  { data_type => "numeric", is_nullable => 0 },
  "mu_vol_r",
  { data_type => "numeric", is_nullable => 0 },
  "sd_vol_1",
  { data_type => "numeric", is_nullable => 0 },
  "sd_vol_m",
  { data_type => "numeric", is_nullable => 0 },
  "sd_vol_r",
  { data_type => "numeric", is_nullable => 0 },
  "corr_occ_1m_x_mu_vol_m",
  { data_type => "numeric", is_nullable => 0 },
  "corr_occ_1m_x_sd_vol_r",
  { data_type => "numeric", is_nullable => 0 },
  "corr_occ_1m_x_lag1_occ_r",
  { data_type => "numeric", is_nullable => 0 },
  "cv_volocc_1_x_corr_volocc_1m",
  { data_type => "numeric", is_nullable => 0 },
  "occ_1",
  { data_type => "numeric", is_nullable => 1 },
  "occ_m",
  { data_type => "numeric", is_nullable => 1 },
  "occ_r",
  { data_type => "numeric", is_nullable => 1 },
  "vol_1",
  { data_type => "numeric", is_nullable => 1 },
  "vol_m",
  { data_type => "numeric", is_nullable => 1 },
  "vol_r",
  { data_type => "numeric", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<SpatialVds::Schema::StatsIds>

=cut

__PACKAGE__->belongs_to("id", "SpatialVds::Schema::StatsIds", { id => "id" });

=head2 vds_stats

Type: has_many

Related object: L<SpatialVds::Schema::VdsStats>

=cut

__PACKAGE__->has_many(
  "vds_stats",
  "SpatialVds::Schema::VdsStats",
  { "foreign.stats_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V/vBaj9SVZ2XdoBqVMlheQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
