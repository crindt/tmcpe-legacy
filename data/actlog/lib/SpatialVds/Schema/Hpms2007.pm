package SpatialVds::Schema::Hpms2007;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Hpms2007

=cut

__PACKAGE__->table("hpms_2007");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'hpms_2007_id_seq'

=head2 year_record

  data_type: 'integer'
  is_nullable: 0

=head2 state_code

  data_type: 'integer'
  is_nullable: 0

=head2 reporting_units

  data_type: 'integer'
  is_nullable: 0

=head2 fips

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 section_id

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 is_sample

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 is_donut

  data_type: 'integer'
  is_nullable: 1

=head2 state_control_field

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 county

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 locality

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 street

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 from_name

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 to_name

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 from_ca_pm_pre

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 from_ca_pm

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 to_ca_pm_pre

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 to_ca_pm

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 is_grouped

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 lrs_id

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 begin_lrs

  data_type: 'numeric'
  is_nullable: 1

=head2 end_lrs

  data_type: 'numeric'
  is_nullable: 1

=head2 rural_urban

  data_type: 'numeric'
  is_nullable: 1

=head2 sampling_tech

  data_type: 'numeric'
  is_nullable: 1

=head2 urban_code

  data_type: 'numeric'
  is_nullable: 1

=head2 nonatt_code

  data_type: 'numeric'
  is_nullable: 1

=head2 f_system

  data_type: 'numeric'
  is_nullable: 1

=head2 gf_system

  data_type: 'numeric'
  is_nullable: 1

=head2 nhs

  data_type: 'numeric'
  is_nullable: 1

=head2 unbuilt_facility

  data_type: 'numeric'
  is_nullable: 1

=head2 inter_route_number

  data_type: 'numeric'
  is_nullable: 1

=head2 route_signing

  data_type: 'numeric'
  is_nullable: 1

=head2 route_qualifier

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 route_number

  data_type: 'numeric'
  is_nullable: 1

=head2 ownership

  data_type: 'numeric'
  is_nullable: 1

=head2 special_systems

  data_type: 'numeric'
  is_nullable: 1

=head2 type_facility

  data_type: 'numeric'
  is_nullable: 1

=head2 truck_route

  data_type: 'numeric'
  is_nullable: 1

=head2 toll

  data_type: 'numeric'
  is_nullable: 1

=head2 section_length

  data_type: 'numeric'
  is_nullable: 1

=head2 donut_volume_group

  data_type: 'numeric'
  is_nullable: 1

=head2 std_volume_group

  data_type: 'numeric'
  is_nullable: 1

=head2 aadt

  data_type: 'numeric'
  is_nullable: 1

=head2 through_lanes

  data_type: 'numeric'
  is_nullable: 1

=head2 iri

  data_type: 'numeric'
  is_nullable: 1

=head2 psr

  data_type: 'numeric'
  is_nullable: 1

=head2 hov

  data_type: 'numeric'
  is_nullable: 1

=head2 surv_a

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 surv_b

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 surv_c

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 surv_d

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 surv_e

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 surv_f

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 surv_g

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 surv_h

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 surv_i

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 sample_id

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 donut_exp_factor

  data_type: 'numeric'
  is_nullable: 1

=head2 std_exp_factor

  data_type: 'numeric'
  is_nullable: 1

=head2 pavement_type

  data_type: 'numeric'
  is_nullable: 1

=head2 sn_d

  data_type: 'numeric'
  is_nullable: 1

=head2 climate_zone

  data_type: 'numeric'
  is_nullable: 1

=head2 year_surf_impov

  data_type: 'numeric'
  is_nullable: 1

=head2 lane_width

  data_type: 'numeric'
  is_nullable: 1

=head2 access_control

  data_type: 'numeric'
  is_nullable: 1

=head2 median_type

  data_type: 'numeric'
  is_nullable: 1

=head2 median_width

  data_type: 'numeric'
  is_nullable: 1

=head2 shoulder_type

  data_type: 'numeric'
  is_nullable: 1

=head2 shoulder_width_r

  data_type: 'numeric'
  is_nullable: 1

=head2 shoulder_width_l

  data_type: 'numeric'
  is_nullable: 1

=head2 peak_parking

  data_type: 'numeric'
  is_nullable: 1

=head2 wide_feas

  data_type: 'numeric'
  is_nullable: 1

=head2 curves_a

  data_type: 'numeric'
  is_nullable: 1

=head2 curves_b

  data_type: 'numeric'
  is_nullable: 1

=head2 curves_c

  data_type: 'numeric'
  is_nullable: 1

=head2 curves_d

  data_type: 'numeric'
  is_nullable: 1

=head2 curves_e

  data_type: 'numeric'
  is_nullable: 1

=head2 curves_f

  data_type: 'numeric'
  is_nullable: 1

=head2 horz_align

  data_type: 'numeric'
  is_nullable: 1

=head2 type_terrain

  data_type: 'numeric'
  is_nullable: 1

=head2 vert_align

  data_type: 'numeric'
  is_nullable: 1

=head2 grades_a

  data_type: 'numeric'
  is_nullable: 1

=head2 grades_b

  data_type: 'numeric'
  is_nullable: 1

=head2 grades_c

  data_type: 'numeric'
  is_nullable: 1

=head2 grades_d

  data_type: 'numeric'
  is_nullable: 1

=head2 grades_e

  data_type: 'numeric'
  is_nullable: 1

=head2 grades_f

  data_type: 'numeric'
  is_nullable: 1

=head2 perc_sight

  data_type: 'numeric'
  is_nullable: 1

=head2 design_speed

  data_type: 'numeric'
  is_nullable: 1

=head2 speed_limit

  data_type: 'numeric'
  is_nullable: 1

=head2 perc_single_unit

  data_type: 'numeric'
  is_nullable: 1

=head2 avg_single_unit

  data_type: 'numeric'
  is_nullable: 1

=head2 perc_combination

  data_type: 'numeric'
  is_nullable: 1

=head2 avg_combination

  data_type: 'numeric'
  is_nullable: 1

=head2 k_factor

  data_type: 'numeric'
  is_nullable: 1

=head2 dir_factor

  data_type: 'numeric'
  is_nullable: 1

=head2 peak_lanes

  data_type: 'numeric'
  is_nullable: 1

=head2 turn_lanes_l

  data_type: 'numeric'
  is_nullable: 1

=head2 turn_lanes_r

  data_type: 'numeric'
  is_nullable: 1

=head2 type_signal

  data_type: 'numeric'
  is_nullable: 1

=head2 perc_green

  data_type: 'numeric'
  is_nullable: 1

=head2 at_grade_signal

  data_type: 'numeric'
  is_nullable: 1

=head2 at_grade_signs

  data_type: 'numeric'
  is_nullable: 1

=head2 at_grade_other

  data_type: 'numeric'
  is_nullable: 1

=head2 peak_capacity

  data_type: 'numeric'
  is_nullable: 1

=head2 vsf

  data_type: 'numeric'
  is_nullable: 1

=head2 fut_aadt

  data_type: 'numeric'
  is_nullable: 1

=head2 fut_aadt_year

  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "hpms_2007_id_seq",
  },
  "year_record",
  { data_type => "integer", is_nullable => 0 },
  "state_code",
  { data_type => "integer", is_nullable => 0 },
  "reporting_units",
  { data_type => "integer", is_nullable => 0 },
  "fips",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "section_id",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "is_sample",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "is_donut",
  { data_type => "integer", is_nullable => 1 },
  "state_control_field",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "county",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "locality",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "street",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "from_name",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "to_name",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "from_ca_pm_pre",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "from_ca_pm",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "to_ca_pm_pre",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "to_ca_pm",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "is_grouped",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "lrs_id",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "begin_lrs",
  { data_type => "numeric", is_nullable => 1 },
  "end_lrs",
  { data_type => "numeric", is_nullable => 1 },
  "rural_urban",
  { data_type => "numeric", is_nullable => 1 },
  "sampling_tech",
  { data_type => "numeric", is_nullable => 1 },
  "urban_code",
  { data_type => "numeric", is_nullable => 1 },
  "nonatt_code",
  { data_type => "numeric", is_nullable => 1 },
  "f_system",
  { data_type => "numeric", is_nullable => 1 },
  "gf_system",
  { data_type => "numeric", is_nullable => 1 },
  "nhs",
  { data_type => "numeric", is_nullable => 1 },
  "unbuilt_facility",
  { data_type => "numeric", is_nullable => 1 },
  "inter_route_number",
  { data_type => "numeric", is_nullable => 1 },
  "route_signing",
  { data_type => "numeric", is_nullable => 1 },
  "route_qualifier",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "route_number",
  { data_type => "numeric", is_nullable => 1 },
  "ownership",
  { data_type => "numeric", is_nullable => 1 },
  "special_systems",
  { data_type => "numeric", is_nullable => 1 },
  "type_facility",
  { data_type => "numeric", is_nullable => 1 },
  "truck_route",
  { data_type => "numeric", is_nullable => 1 },
  "toll",
  { data_type => "numeric", is_nullable => 1 },
  "section_length",
  { data_type => "numeric", is_nullable => 1 },
  "donut_volume_group",
  { data_type => "numeric", is_nullable => 1 },
  "std_volume_group",
  { data_type => "numeric", is_nullable => 1 },
  "aadt",
  { data_type => "numeric", is_nullable => 1 },
  "through_lanes",
  { data_type => "numeric", is_nullable => 1 },
  "iri",
  { data_type => "numeric", is_nullable => 1 },
  "psr",
  { data_type => "numeric", is_nullable => 1 },
  "hov",
  { data_type => "numeric", is_nullable => 1 },
  "surv_a",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "surv_b",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "surv_c",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "surv_d",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "surv_e",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "surv_f",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "surv_g",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "surv_h",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "surv_i",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "sample_id",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "donut_exp_factor",
  { data_type => "numeric", is_nullable => 1 },
  "std_exp_factor",
  { data_type => "numeric", is_nullable => 1 },
  "pavement_type",
  { data_type => "numeric", is_nullable => 1 },
  "sn_d",
  { data_type => "numeric", is_nullable => 1 },
  "climate_zone",
  { data_type => "numeric", is_nullable => 1 },
  "year_surf_impov",
  { data_type => "numeric", is_nullable => 1 },
  "lane_width",
  { data_type => "numeric", is_nullable => 1 },
  "access_control",
  { data_type => "numeric", is_nullable => 1 },
  "median_type",
  { data_type => "numeric", is_nullable => 1 },
  "median_width",
  { data_type => "numeric", is_nullable => 1 },
  "shoulder_type",
  { data_type => "numeric", is_nullable => 1 },
  "shoulder_width_r",
  { data_type => "numeric", is_nullable => 1 },
  "shoulder_width_l",
  { data_type => "numeric", is_nullable => 1 },
  "peak_parking",
  { data_type => "numeric", is_nullable => 1 },
  "wide_feas",
  { data_type => "numeric", is_nullable => 1 },
  "curves_a",
  { data_type => "numeric", is_nullable => 1 },
  "curves_b",
  { data_type => "numeric", is_nullable => 1 },
  "curves_c",
  { data_type => "numeric", is_nullable => 1 },
  "curves_d",
  { data_type => "numeric", is_nullable => 1 },
  "curves_e",
  { data_type => "numeric", is_nullable => 1 },
  "curves_f",
  { data_type => "numeric", is_nullable => 1 },
  "horz_align",
  { data_type => "numeric", is_nullable => 1 },
  "type_terrain",
  { data_type => "numeric", is_nullable => 1 },
  "vert_align",
  { data_type => "numeric", is_nullable => 1 },
  "grades_a",
  { data_type => "numeric", is_nullable => 1 },
  "grades_b",
  { data_type => "numeric", is_nullable => 1 },
  "grades_c",
  { data_type => "numeric", is_nullable => 1 },
  "grades_d",
  { data_type => "numeric", is_nullable => 1 },
  "grades_e",
  { data_type => "numeric", is_nullable => 1 },
  "grades_f",
  { data_type => "numeric", is_nullable => 1 },
  "perc_sight",
  { data_type => "numeric", is_nullable => 1 },
  "design_speed",
  { data_type => "numeric", is_nullable => 1 },
  "speed_limit",
  { data_type => "numeric", is_nullable => 1 },
  "perc_single_unit",
  { data_type => "numeric", is_nullable => 1 },
  "avg_single_unit",
  { data_type => "numeric", is_nullable => 1 },
  "perc_combination",
  { data_type => "numeric", is_nullable => 1 },
  "avg_combination",
  { data_type => "numeric", is_nullable => 1 },
  "k_factor",
  { data_type => "numeric", is_nullable => 1 },
  "dir_factor",
  { data_type => "numeric", is_nullable => 1 },
  "peak_lanes",
  { data_type => "numeric", is_nullable => 1 },
  "turn_lanes_l",
  { data_type => "numeric", is_nullable => 1 },
  "turn_lanes_r",
  { data_type => "numeric", is_nullable => 1 },
  "type_signal",
  { data_type => "numeric", is_nullable => 1 },
  "perc_green",
  { data_type => "numeric", is_nullable => 1 },
  "at_grade_signal",
  { data_type => "numeric", is_nullable => 1 },
  "at_grade_signs",
  { data_type => "numeric", is_nullable => 1 },
  "at_grade_other",
  { data_type => "numeric", is_nullable => 1 },
  "peak_capacity",
  { data_type => "numeric", is_nullable => 1 },
  "vsf",
  { data_type => "numeric", is_nullable => 1 },
  "fut_aadt",
  { data_type => "numeric", is_nullable => 1 },
  "fut_aadt_year",
  { data_type => "numeric", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VzMHoydWadCKRwD1HtIFQQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
