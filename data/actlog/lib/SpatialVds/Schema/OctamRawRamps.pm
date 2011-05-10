package SpatialVds::Schema::OctamRawRamps;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamRawRamps

=cut

__PACKAGE__->table("octam_raw_ramps");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_nullable: 1

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 length

  data_type: 'double precision'
  is_nullable: 1

=head2 dir

  data_type: 'smallint'
  is_nullable: 1

=head2 vds

  data_type: 'integer'
  is_nullable: 1

=head2 sr91_vds

  data_type: 'integer'
  is_nullable: 1

=head2 ab_locatio

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 ba_locatio

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 sr57_vds

  data_type: 'integer'
  is_nullable: 1

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 new_ab_cap

  data_type: 'double precision'
  is_nullable: 1

=head2 capacitycl

  data_type: 'double precision'
  is_nullable: 1

=head2 abs_pm

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 f67am

  data_type: 'double precision'
  is_nullable: 1

=head2 f78am

  data_type: 'double precision'
  is_nullable: 1

=head2 f89am

  data_type: 'double precision'
  is_nullable: 1

=head2 f910am

  data_type: 'double precision'
  is_nullable: 1

=head2 vds_69amfl

  data_type: 'integer'
  is_nullable: 1

=head2 f23pm

  data_type: 'double precision'
  is_nullable: 1

=head2 f34pm

  data_type: 'double precision'
  is_nullable: 1

=head2 f45pm

  data_type: 'double precision'
  is_nullable: 1

=head2 f56pm

  data_type: 'double precision'
  is_nullable: 1

=head2 f67pm

  data_type: 'double precision'
  is_nullable: 1

=head2 f78pm

  data_type: 'double precision'
  is_nullable: 1

=head2 vds_37pmfl

  data_type: 'integer'
  is_nullable: 1

=head2 hasabflow

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 hasbaflow

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 obs_ab_flo

  data_type: 'integer'
  is_nullable: 1

=head2 obs_ba_flo

  data_type: 'integer'
  is_nullable: 1

=head2 facility_t

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 roadway_na

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 ft_code

  data_type: 'bigint'
  is_nullable: 1

=head2 ff_speed

  data_type: 'bigint'
  is_nullable: 1

=head2 speed_upd

  data_type: 'integer'
  is_nullable: 1

=head2 speed_upd_

  data_type: 'integer'
  is_nullable: 1

=head2 capa_upd_v

  data_type: 'integer'
  is_nullable: 1

=head2 ff_ttime

  data_type: 'double precision'
  is_nullable: 1

=head2 auxiliary_

  data_type: 'integer'
  is_nullable: 1

=head2 capacity

  data_type: 'bigint'
  is_nullable: 1

=head2 walk_links

  data_type: 'bigint'
  is_nullable: 1

=head2 drive_link

  data_type: 'bigint'
  is_nullable: 1

=head2 walk_time

  data_type: 'double precision'
  is_nullable: 1

=head2 fnode_

  data_type: 'bigint'
  is_nullable: 1

=head2 tnode_

  data_type: 'bigint'
  is_nullable: 1

=head2 lpoly_

  data_type: 'bigint'
  is_nullable: 1

=head2 rpoly_

  data_type: 'bigint'
  is_nullable: 1

=head2 length_ft

  data_type: 'double precision'
  is_nullable: 1

=head2 net10_29_

  data_type: 'bigint'
  is_nullable: 1

=head2 net10_29_i

  data_type: 'bigint'
  is_nullable: 1

=head2 anode

  data_type: 'integer'
  is_nullable: 1

=head2 bnode

  data_type: 'integer'
  is_nullable: 1

=head2 dist

  data_type: 'integer'
  is_nullable: 1

=head2 zfft

  data_type: 'integer'
  is_nullable: 1

=head2 cngt

  data_type: 'integer'
  is_nullable: 1

=head2 dr

  data_type: 'integer'
  is_nullable: 1

=head2 l3

  data_type: 'integer'
  is_nullable: 1

=head2 z_amvc

  data_type: 'integer'
  is_nullable: 1

=head2 z_pmvc

  data_type: 'integer'
  is_nullable: 1

=head2 s

  data_type: 'varchar'
  is_nullable: 1
  size: 9

=head2 screenline

  data_type: 'integer'
  is_nullable: 1

=head2 ab_count

  data_type: 'integer'
  is_nullable: 1

=head2 ba_count

  data_type: 'integer'
  is_nullable: 1

=head2 a_2000

  data_type: 'integer'
  is_nullable: 1

=head2 l1_2000

  data_type: 'integer'
  is_nullable: 1

=head2 ab_l2_2000

  data_type: 'integer'
  is_nullable: 1

=head2 ba_l2_2000

  data_type: 'integer'
  is_nullable: 1

=head2 a_const

  data_type: 'integer'
  is_nullable: 1

=head2 l1_const

  data_type: 'integer'
  is_nullable: 1

=head2 ab_l2_cons

  data_type: 'integer'
  is_nullable: 1

=head2 ba_l2_cons

  data_type: 'integer'
  is_nullable: 1

=head2 a_mpah

  data_type: 'integer'
  is_nullable: 1

=head2 l1_mpah

  data_type: 'integer'
  is_nullable: 1

=head2 ab_l2_mpah

  data_type: 'integer'
  is_nullable: 1

=head2 ba_l2_mpah

  data_type: 'integer'
  is_nullable: 1

=head2 toll_value

  data_type: 'integer'
  is_nullable: 1

=head2 gc3

  data_type: 'integer'
  is_nullable: 1

=head2 vdf

  data_type: 'integer'
  is_nullable: 1

=head2 ab_speed_f

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_speed_f

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_speed_p

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_speed_p

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_speed_o

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_speed_o

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_capa_ff

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_capa_ff

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_capa_pk

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_capa_pk

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_capa_op

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_capa_op

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_toll_ff

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_toll_ff

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_toll_pk

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_toll_pk

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_toll_op

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_toll_op

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_time_ff

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_time_ff

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_time_pk

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_time_pk

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_time_op

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_time_op

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_group_3

  data_type: 'integer'
  is_nullable: 1

=head2 ab_key

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 akcelik_a

  data_type: 'double precision'
  is_nullable: 1

=head2 akcelik_c

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_group_3

  data_type: 'integer'
  is_nullable: 1

=head2 ba_key

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 old_ab_cap

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_capa_am

  data_type: 'double precision'
  is_nullable: 1

=head2 old_ba_cap

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_capa_am

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_capa_pm

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_capa_pm

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_capa_md

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_capa_md

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_capa_nt

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_capa_nt

  data_type: 'double precision'
  is_nullable: 1

=head2 area_type

  data_type: 'integer'
  is_nullable: 1

=head2 sub_crossi

  data_type: 'integer'
  is_nullable: 1

=head2 sub_links

  data_type: 'integer'
  is_nullable: 1

=head2 ab_am69_co

  data_type: 'integer'
  is_nullable: 1

=head2 ba_am69_co

  data_type: 'integer'
  is_nullable: 1

=head2 ab_cnt69_d

  data_type: 'integer'
  is_nullable: 1

=head2 ba_cnt69_d

  data_type: 'integer'
  is_nullable: 1

=head2 ab_cnt69_1

  data_type: 'integer'
  is_nullable: 1

=head2 ba_cnt69_1

  data_type: 'integer'
  is_nullable: 1

=head2 ab_cnt69_h

  data_type: 'integer'
  is_nullable: 1

=head2 ba_cnt69_h

  data_type: 'integer'
  is_nullable: 1

=head2 ab_cnt69_2

  data_type: 'integer'
  is_nullable: 1

=head2 ba_cnt69_2

  data_type: 'integer'
  is_nullable: 1

=head2 ab_pm37_co

  data_type: 'integer'
  is_nullable: 1

=head2 ba_pm37_co

  data_type: 'integer'
  is_nullable: 1

=head2 ab_cnt37_d

  data_type: 'integer'
  is_nullable: 1

=head2 ba_cnt37_d

  data_type: 'integer'
  is_nullable: 1

=head2 ab_cnt37_1

  data_type: 'integer'
  is_nullable: 1

=head2 ba_cnt37_1

  data_type: 'integer'
  is_nullable: 1

=head2 ab_cnt37_h

  data_type: 'integer'
  is_nullable: 1

=head2 ba_cnt37_h

  data_type: 'integer'
  is_nullable: 1

=head2 ab_cnt37_2

  data_type: 'integer'
  is_nullable: 1

=head2 ba_cnt37_2

  data_type: 'integer'
  is_nullable: 1

=head2 ab_wgt

  data_type: 'integer'
  is_nullable: 1

=head2 ba_wgt

  data_type: 'integer'
  is_nullable: 1

=head2 sr91micro

  data_type: 'integer'
  is_nullable: 1

=head2 sr91macro

  data_type: 'integer'
  is_nullable: 1

=head2 sr57micro

  data_type: 'integer'
  is_nullable: 1

=head2 sr57macro

  data_type: 'integer'
  is_nullable: 1

=head2 clradjuste

  data_type: 'integer'
  is_nullable: 1

=head2 dist_ag0

  data_type: 'double precision'
  is_nullable: 1

=head2 dist_ag7

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_time_p1

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_time_p1

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_time_o1

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_time_o1

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_dist_lg

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_time_p2

  data_type: 'double precision'
  is_nullable: 1

=head2 ab_time_o2

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_dist_lg

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_time_p2

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_time_o2

  data_type: 'double precision'
  is_nullable: 1

=head2 the_geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  { data_type => "integer", is_nullable => 1 },
  "id",
  { data_type => "integer", is_nullable => 1 },
  "length",
  { data_type => "double precision", is_nullable => 1 },
  "dir",
  { data_type => "smallint", is_nullable => 1 },
  "vds",
  { data_type => "integer", is_nullable => 1 },
  "sr91_vds",
  { data_type => "integer", is_nullable => 1 },
  "ab_locatio",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "ba_locatio",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "sr57_vds",
  { data_type => "integer", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "new_ab_cap",
  { data_type => "double precision", is_nullable => 1 },
  "capacitycl",
  { data_type => "double precision", is_nullable => 1 },
  "abs_pm",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "f67am",
  { data_type => "double precision", is_nullable => 1 },
  "f78am",
  { data_type => "double precision", is_nullable => 1 },
  "f89am",
  { data_type => "double precision", is_nullable => 1 },
  "f910am",
  { data_type => "double precision", is_nullable => 1 },
  "vds_69amfl",
  { data_type => "integer", is_nullable => 1 },
  "f23pm",
  { data_type => "double precision", is_nullable => 1 },
  "f34pm",
  { data_type => "double precision", is_nullable => 1 },
  "f45pm",
  { data_type => "double precision", is_nullable => 1 },
  "f56pm",
  { data_type => "double precision", is_nullable => 1 },
  "f67pm",
  { data_type => "double precision", is_nullable => 1 },
  "f78pm",
  { data_type => "double precision", is_nullable => 1 },
  "vds_37pmfl",
  { data_type => "integer", is_nullable => 1 },
  "hasabflow",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "hasbaflow",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "obs_ab_flo",
  { data_type => "integer", is_nullable => 1 },
  "obs_ba_flo",
  { data_type => "integer", is_nullable => 1 },
  "facility_t",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "roadway_na",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "ft_code",
  { data_type => "bigint", is_nullable => 1 },
  "ff_speed",
  { data_type => "bigint", is_nullable => 1 },
  "speed_upd",
  { data_type => "integer", is_nullable => 1 },
  "speed_upd_",
  { data_type => "integer", is_nullable => 1 },
  "capa_upd_v",
  { data_type => "integer", is_nullable => 1 },
  "ff_ttime",
  { data_type => "double precision", is_nullable => 1 },
  "auxiliary_",
  { data_type => "integer", is_nullable => 1 },
  "capacity",
  { data_type => "bigint", is_nullable => 1 },
  "walk_links",
  { data_type => "bigint", is_nullable => 1 },
  "drive_link",
  { data_type => "bigint", is_nullable => 1 },
  "walk_time",
  { data_type => "double precision", is_nullable => 1 },
  "fnode_",
  { data_type => "bigint", is_nullable => 1 },
  "tnode_",
  { data_type => "bigint", is_nullable => 1 },
  "lpoly_",
  { data_type => "bigint", is_nullable => 1 },
  "rpoly_",
  { data_type => "bigint", is_nullable => 1 },
  "length_ft",
  { data_type => "double precision", is_nullable => 1 },
  "net10_29_",
  { data_type => "bigint", is_nullable => 1 },
  "net10_29_i",
  { data_type => "bigint", is_nullable => 1 },
  "anode",
  { data_type => "integer", is_nullable => 1 },
  "bnode",
  { data_type => "integer", is_nullable => 1 },
  "dist",
  { data_type => "integer", is_nullable => 1 },
  "zfft",
  { data_type => "integer", is_nullable => 1 },
  "cngt",
  { data_type => "integer", is_nullable => 1 },
  "dr",
  { data_type => "integer", is_nullable => 1 },
  "l3",
  { data_type => "integer", is_nullable => 1 },
  "z_amvc",
  { data_type => "integer", is_nullable => 1 },
  "z_pmvc",
  { data_type => "integer", is_nullable => 1 },
  "s",
  { data_type => "varchar", is_nullable => 1, size => 9 },
  "screenline",
  { data_type => "integer", is_nullable => 1 },
  "ab_count",
  { data_type => "integer", is_nullable => 1 },
  "ba_count",
  { data_type => "integer", is_nullable => 1 },
  "a_2000",
  { data_type => "integer", is_nullable => 1 },
  "l1_2000",
  { data_type => "integer", is_nullable => 1 },
  "ab_l2_2000",
  { data_type => "integer", is_nullable => 1 },
  "ba_l2_2000",
  { data_type => "integer", is_nullable => 1 },
  "a_const",
  { data_type => "integer", is_nullable => 1 },
  "l1_const",
  { data_type => "integer", is_nullable => 1 },
  "ab_l2_cons",
  { data_type => "integer", is_nullable => 1 },
  "ba_l2_cons",
  { data_type => "integer", is_nullable => 1 },
  "a_mpah",
  { data_type => "integer", is_nullable => 1 },
  "l1_mpah",
  { data_type => "integer", is_nullable => 1 },
  "ab_l2_mpah",
  { data_type => "integer", is_nullable => 1 },
  "ba_l2_mpah",
  { data_type => "integer", is_nullable => 1 },
  "toll_value",
  { data_type => "integer", is_nullable => 1 },
  "gc3",
  { data_type => "integer", is_nullable => 1 },
  "vdf",
  { data_type => "integer", is_nullable => 1 },
  "ab_speed_f",
  { data_type => "double precision", is_nullable => 1 },
  "ba_speed_f",
  { data_type => "double precision", is_nullable => 1 },
  "ab_speed_p",
  { data_type => "double precision", is_nullable => 1 },
  "ba_speed_p",
  { data_type => "double precision", is_nullable => 1 },
  "ab_speed_o",
  { data_type => "double precision", is_nullable => 1 },
  "ba_speed_o",
  { data_type => "double precision", is_nullable => 1 },
  "ab_capa_ff",
  { data_type => "double precision", is_nullable => 1 },
  "ba_capa_ff",
  { data_type => "double precision", is_nullable => 1 },
  "ab_capa_pk",
  { data_type => "double precision", is_nullable => 1 },
  "ba_capa_pk",
  { data_type => "double precision", is_nullable => 1 },
  "ab_capa_op",
  { data_type => "double precision", is_nullable => 1 },
  "ba_capa_op",
  { data_type => "double precision", is_nullable => 1 },
  "ab_toll_ff",
  { data_type => "double precision", is_nullable => 1 },
  "ba_toll_ff",
  { data_type => "double precision", is_nullable => 1 },
  "ab_toll_pk",
  { data_type => "double precision", is_nullable => 1 },
  "ba_toll_pk",
  { data_type => "double precision", is_nullable => 1 },
  "ab_toll_op",
  { data_type => "double precision", is_nullable => 1 },
  "ba_toll_op",
  { data_type => "double precision", is_nullable => 1 },
  "ab_time_ff",
  { data_type => "double precision", is_nullable => 1 },
  "ba_time_ff",
  { data_type => "double precision", is_nullable => 1 },
  "ab_time_pk",
  { data_type => "double precision", is_nullable => 1 },
  "ba_time_pk",
  { data_type => "double precision", is_nullable => 1 },
  "ab_time_op",
  { data_type => "double precision", is_nullable => 1 },
  "ba_time_op",
  { data_type => "double precision", is_nullable => 1 },
  "ab_group_3",
  { data_type => "integer", is_nullable => 1 },
  "ab_key",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "akcelik_a",
  { data_type => "double precision", is_nullable => 1 },
  "akcelik_c",
  { data_type => "double precision", is_nullable => 1 },
  "ba_group_3",
  { data_type => "integer", is_nullable => 1 },
  "ba_key",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "old_ab_cap",
  { data_type => "double precision", is_nullable => 1 },
  "ab_capa_am",
  { data_type => "double precision", is_nullable => 1 },
  "old_ba_cap",
  { data_type => "double precision", is_nullable => 1 },
  "ba_capa_am",
  { data_type => "double precision", is_nullable => 1 },
  "ab_capa_pm",
  { data_type => "double precision", is_nullable => 1 },
  "ba_capa_pm",
  { data_type => "double precision", is_nullable => 1 },
  "ab_capa_md",
  { data_type => "double precision", is_nullable => 1 },
  "ba_capa_md",
  { data_type => "double precision", is_nullable => 1 },
  "ab_capa_nt",
  { data_type => "double precision", is_nullable => 1 },
  "ba_capa_nt",
  { data_type => "double precision", is_nullable => 1 },
  "area_type",
  { data_type => "integer", is_nullable => 1 },
  "sub_crossi",
  { data_type => "integer", is_nullable => 1 },
  "sub_links",
  { data_type => "integer", is_nullable => 1 },
  "ab_am69_co",
  { data_type => "integer", is_nullable => 1 },
  "ba_am69_co",
  { data_type => "integer", is_nullable => 1 },
  "ab_cnt69_d",
  { data_type => "integer", is_nullable => 1 },
  "ba_cnt69_d",
  { data_type => "integer", is_nullable => 1 },
  "ab_cnt69_1",
  { data_type => "integer", is_nullable => 1 },
  "ba_cnt69_1",
  { data_type => "integer", is_nullable => 1 },
  "ab_cnt69_h",
  { data_type => "integer", is_nullable => 1 },
  "ba_cnt69_h",
  { data_type => "integer", is_nullable => 1 },
  "ab_cnt69_2",
  { data_type => "integer", is_nullable => 1 },
  "ba_cnt69_2",
  { data_type => "integer", is_nullable => 1 },
  "ab_pm37_co",
  { data_type => "integer", is_nullable => 1 },
  "ba_pm37_co",
  { data_type => "integer", is_nullable => 1 },
  "ab_cnt37_d",
  { data_type => "integer", is_nullable => 1 },
  "ba_cnt37_d",
  { data_type => "integer", is_nullable => 1 },
  "ab_cnt37_1",
  { data_type => "integer", is_nullable => 1 },
  "ba_cnt37_1",
  { data_type => "integer", is_nullable => 1 },
  "ab_cnt37_h",
  { data_type => "integer", is_nullable => 1 },
  "ba_cnt37_h",
  { data_type => "integer", is_nullable => 1 },
  "ab_cnt37_2",
  { data_type => "integer", is_nullable => 1 },
  "ba_cnt37_2",
  { data_type => "integer", is_nullable => 1 },
  "ab_wgt",
  { data_type => "integer", is_nullable => 1 },
  "ba_wgt",
  { data_type => "integer", is_nullable => 1 },
  "sr91micro",
  { data_type => "integer", is_nullable => 1 },
  "sr91macro",
  { data_type => "integer", is_nullable => 1 },
  "sr57micro",
  { data_type => "integer", is_nullable => 1 },
  "sr57macro",
  { data_type => "integer", is_nullable => 1 },
  "clradjuste",
  { data_type => "integer", is_nullable => 1 },
  "dist_ag0",
  { data_type => "double precision", is_nullable => 1 },
  "dist_ag7",
  { data_type => "double precision", is_nullable => 1 },
  "ab_time_p1",
  { data_type => "double precision", is_nullable => 1 },
  "ba_time_p1",
  { data_type => "double precision", is_nullable => 1 },
  "ab_time_o1",
  { data_type => "double precision", is_nullable => 1 },
  "ba_time_o1",
  { data_type => "double precision", is_nullable => 1 },
  "ab_dist_lg",
  { data_type => "double precision", is_nullable => 1 },
  "ab_time_p2",
  { data_type => "double precision", is_nullable => 1 },
  "ab_time_o2",
  { data_type => "double precision", is_nullable => 1 },
  "ba_dist_lg",
  { data_type => "double precision", is_nullable => 1 },
  "ba_time_p2",
  { data_type => "double precision", is_nullable => 1 },
  "ba_time_o2",
  { data_type => "double precision", is_nullable => 1 },
  "the_geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WA+HstS/8R+8W7SjXHlWHA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
