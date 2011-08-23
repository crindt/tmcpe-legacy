package SpatialVds::Schema::SjvNetworkLinks;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::SjvNetworkLinks

=cut

__PACKAGE__->table("sjv_network_links");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'sjv_network_links_gid_seq'

=head2 a

  data_type: 'integer'
  is_nullable: 1

=head2 b

  data_type: 'integer'
  is_nullable: 1

=head2 distance

  data_type: 'double precision'
  is_nullable: 1

=head2 capclass

  data_type: 'smallint'
  is_nullable: 1

=head2 stname

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 region

  data_type: 'varchar'
  is_nullable: 1
  size: 11

=head2 speed

  data_type: 'smallint'
  is_nullable: 1

=head2 count_am06

  data_type: 'smallint'
  is_nullable: 1

=head2 count_pm06

  data_type: 'smallint'
  is_nullable: 1

=head2 lanes

  data_type: 'smallint'
  is_nullable: 1

=head2 cnt

  data_type: 'smallint'
  is_nullable: 1

=head2 capacity

  data_type: 'integer'
  is_nullable: 1

=head2 v_31

  data_type: 'double precision'
  is_nullable: 1

=head2 time_31

  data_type: 'double precision'
  is_nullable: 1

=head2 vc_31

  data_type: 'double precision'
  is_nullable: 1

=head2 cspd_31

  data_type: 'double precision'
  is_nullable: 1

=head2 vdt_31

  data_type: 'double precision'
  is_nullable: 1

=head2 vht_31

  data_type: 'double precision'
  is_nullable: 1

=head2 v1_31

  data_type: 'double precision'
  is_nullable: 1

=head2 vt_31

  data_type: 'double precision'
  is_nullable: 1

=head2 v1t_31

  data_type: 'double precision'
  is_nullable: 1

=head2 the_geom

  data_type: 'geometry'
  is_nullable: 1

=head2 geom_3310

  data_type: 'geometry'
  is_nullable: 1

=head2 geom_4326

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "sjv_network_links_gid_seq",
  },
  "a",
  { data_type => "integer", is_nullable => 1 },
  "b",
  { data_type => "integer", is_nullable => 1 },
  "distance",
  { data_type => "double precision", is_nullable => 1 },
  "capclass",
  { data_type => "smallint", is_nullable => 1 },
  "stname",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "region",
  { data_type => "varchar", is_nullable => 1, size => 11 },
  "speed",
  { data_type => "smallint", is_nullable => 1 },
  "count_am06",
  { data_type => "smallint", is_nullable => 1 },
  "count_pm06",
  { data_type => "smallint", is_nullable => 1 },
  "lanes",
  { data_type => "smallint", is_nullable => 1 },
  "cnt",
  { data_type => "smallint", is_nullable => 1 },
  "capacity",
  { data_type => "integer", is_nullable => 1 },
  "v_31",
  { data_type => "double precision", is_nullable => 1 },
  "time_31",
  { data_type => "double precision", is_nullable => 1 },
  "vc_31",
  { data_type => "double precision", is_nullable => 1 },
  "cspd_31",
  { data_type => "double precision", is_nullable => 1 },
  "vdt_31",
  { data_type => "double precision", is_nullable => 1 },
  "vht_31",
  { data_type => "double precision", is_nullable => 1 },
  "v1_31",
  { data_type => "double precision", is_nullable => 1 },
  "vt_31",
  { data_type => "double precision", is_nullable => 1 },
  "v1t_31",
  { data_type => "double precision", is_nullable => 1 },
  "the_geom",
  { data_type => "geometry", is_nullable => 1 },
  "geom_3310",
  { data_type => "geometry", is_nullable => 1 },
  "geom_4326",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9H51bE1QJf8Ce1qwo4IIzw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
