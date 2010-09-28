package SpatialVds::Schema::Hpms2007;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("hpms_2007");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('hpms_2007_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "year_record",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "state_code",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "reporting_units",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "fips",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "section_id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "is_sample",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "is_donut",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "state_control_field",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "county",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "locality",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "street",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "from_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "to_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "from_ca_pm_pre",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "from_ca_pm",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "to_ca_pm_pre",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "to_ca_pm",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "is_grouped",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "lrs_id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "begin_lrs",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "end_lrs",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "rural_urban",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "sampling_tech",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "urban_code",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "nonatt_code",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "f_system",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "gf_system",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "nhs",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "unbuilt_facility",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "inter_route_number",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "route_signing",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "route_qualifier",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "route_number",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ownership",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "special_systems",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "type_facility",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "truck_route",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "toll",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "section_length",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "donut_volume_group",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "std_volume_group",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "aadt",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "through_lanes",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "iri",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "psr",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "hov",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_a",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_b",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_c",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_d",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_e",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_f",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_g",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_h",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "surv_i",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "sample_id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "donut_exp_factor",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "std_exp_factor",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "pavement_type",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "sn_d",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "climate_zone",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "year_surf_impov",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "lane_width",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "access_control",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "median_type",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "median_width",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "shoulder_type",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "shoulder_width_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "shoulder_width_l",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "peak_parking",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "wide_feas",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "curves_a",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "curves_b",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "curves_c",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "curves_d",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "curves_e",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "curves_f",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "horz_align",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "type_terrain",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "vert_align",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "grades_a",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "grades_b",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "grades_c",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "grades_d",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "grades_e",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "grades_f",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "perc_sight",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "design_speed",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "speed_limit",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "perc_single_unit",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "avg_single_unit",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "perc_combination",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "avg_combination",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "k_factor",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "dir_factor",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "peak_lanes",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "turn_lanes_l",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "turn_lanes_r",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "type_signal",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "perc_green",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "at_grade_signal",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "at_grade_signs",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "at_grade_other",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "peak_capacity",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "vsf",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "fut_aadt",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "fut_aadt_year",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("hpms_2007_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2010-09-27 17:06:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rkZLZVuKx9fnKHmLrw9LVw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
