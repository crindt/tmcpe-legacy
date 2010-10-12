package SpatialVds::Schema::OctamNetworkFlows;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("octam_network_flows");
__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "length",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "dir",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "vds",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sr91_vds",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_locatio",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "ba_locatio",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "sr57_vds",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "type",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "new_ab_cap",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "capacitycl",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "abs_pm",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "f67am",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "f78am",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "f89am",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "f910am",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "vds_69amfl",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "f23pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "f34pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "f45pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "f56pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "f67pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "f78pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "vds_37pmfl",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "hasabflow",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "hasbaflow",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "obs_ab_flo",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "obs_ba_flo",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "facility_t",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 20,
  },
  "roadway_na",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 50,
  },
  "ft_code",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "ff_speed",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "speed_upd",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "speed_upd_",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "capa_upd_v",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ff_ttime",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "auxiliary_",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "capacity",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "walk_links",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "drive_link",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "walk_time",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "fnode_",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "tnode_",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "lpoly_",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "rpoly_",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "length_ft",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "net10_29_",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "net10_29_i",
  { data_type => "bigint", default_value => undef, is_nullable => 1, size => 8 },
  "anode",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "bnode",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "zfft",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "cngt",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "dr",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "l3",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "z_amvc",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "z_pmvc",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "s",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 9,
  },
  "screenline",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_count",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_count",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "a_2000",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "l1_2000",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_l2_2000",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_l2_2000",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "a_const",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "l1_const",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_l2_cons",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_l2_cons",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "a_mpah",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "l1_mpah",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_l2_mpah",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_l2_mpah",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "toll_value",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "gc3",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "vdf",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_speed_f",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_speed_f",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_speed_p",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_speed_p",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_speed_o",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_speed_o",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_capa_ff",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_capa_ff",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_capa_pk",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_capa_pk",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_capa_op",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_capa_op",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_toll_ff",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_toll_ff",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_toll_pk",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_toll_pk",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_toll_op",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_toll_op",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_time_ff",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_time_ff",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_time_pk",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_time_pk",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_time_op",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_time_op",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_group_3",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_key",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "akcelik_a",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "akcelik_c",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_group_3",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_key",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "old_ab_cap",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_capa_am",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "old_ba_cap",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_capa_am",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_capa_pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_capa_pm",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_capa_md",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_capa_md",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_capa_nt",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_capa_nt",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "area_type",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sub_crossi",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sub_links",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_am69_co",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_am69_co",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_cnt69_d",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_cnt69_d",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_cnt69_1",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_cnt69_1",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_cnt69_h",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_cnt69_h",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_cnt69_2",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_cnt69_2",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_pm37_co",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_pm37_co",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_cnt37_d",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_cnt37_d",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_cnt37_1",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_cnt37_1",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_cnt37_h",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_cnt37_h",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_cnt37_2",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_cnt37_2",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ab_wgt",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "ba_wgt",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sr91micro",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sr91macro",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sr57micro",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sr57macro",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "clradjuste",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "dist_ag0",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "dist_ag7",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_time_p1",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_time_p1",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_time_o1",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_time_o1",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_dist_lg",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_time_p2",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_time_o2",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_dist_lg",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_time_p2",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_time_o2",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "the_geom",
  {
    data_type => "geometry",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ab_day_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_day_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "tot_day_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_day_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_day_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "tot_day_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_am_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_am_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "tot_am_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_am_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_am_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "tot_am_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_pm_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_pm_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "tot_pm_00",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ab_pm_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "ba_pm_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "tot_pm_30",
  {
    data_type => "double precision",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-10-12 11:55:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BBl9rwZydBuWY40TzsOqWA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
