package SpatialVds::Schema::SjvNetworkNodes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::SjvNetworkNodes

=cut

__PACKAGE__->table("sjv_network_nodes");

=head1 ACCESSORS

=head2 gid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'sjv_network_nodes_gid_seq'

=head2 n

  data_type: 'integer'
  is_nullable: 1

=head2 x

  data_type: 'double precision'
  is_nullable: 1

=head2 y

  data_type: 'double precision'
  is_nullable: 1

=head2 taz_rgn

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 sf08

  data_type: 'integer'
  is_nullable: 1

=head2 mf08

  data_type: 'integer'
  is_nullable: 1

=head2 ret08

  data_type: 'integer'
  is_nullable: 1

=head2 ser08

  data_type: 'integer'
  is_nullable: 1

=head2 oth08

  data_type: 'integer'
  is_nullable: 1

=head2 sf10

  data_type: 'integer'
  is_nullable: 1

=head2 mf10

  data_type: 'integer'
  is_nullable: 1

=head2 ret10

  data_type: 'integer'
  is_nullable: 1

=head2 ser10

  data_type: 'integer'
  is_nullable: 1

=head2 oth10

  data_type: 'integer'
  is_nullable: 1

=head2 sf11

  data_type: 'integer'
  is_nullable: 1

=head2 mf11

  data_type: 'integer'
  is_nullable: 1

=head2 ret11

  data_type: 'integer'
  is_nullable: 1

=head2 ser11

  data_type: 'integer'
  is_nullable: 1

=head2 oth11

  data_type: 'integer'
  is_nullable: 1

=head2 sf12

  data_type: 'integer'
  is_nullable: 1

=head2 mf12

  data_type: 'integer'
  is_nullable: 1

=head2 ret12

  data_type: 'integer'
  is_nullable: 1

=head2 ser12

  data_type: 'integer'
  is_nullable: 1

=head2 oth12

  data_type: 'integer'
  is_nullable: 1

=head2 sf14

  data_type: 'integer'
  is_nullable: 1

=head2 mf14

  data_type: 'integer'
  is_nullable: 1

=head2 ret14

  data_type: 'integer'
  is_nullable: 1

=head2 ser14

  data_type: 'integer'
  is_nullable: 1

=head2 oth14

  data_type: 'integer'
  is_nullable: 1

=head2 sf17

  data_type: 'integer'
  is_nullable: 1

=head2 mf17

  data_type: 'integer'
  is_nullable: 1

=head2 ret17

  data_type: 'integer'
  is_nullable: 1

=head2 ser17

  data_type: 'integer'
  is_nullable: 1

=head2 oth17

  data_type: 'integer'
  is_nullable: 1

=head2 sf18

  data_type: 'integer'
  is_nullable: 1

=head2 mf18

  data_type: 'integer'
  is_nullable: 1

=head2 ret18

  data_type: 'integer'
  is_nullable: 1

=head2 ser18

  data_type: 'integer'
  is_nullable: 1

=head2 oth18

  data_type: 'integer'
  is_nullable: 1

=head2 sf20

  data_type: 'integer'
  is_nullable: 1

=head2 mf20

  data_type: 'integer'
  is_nullable: 1

=head2 ret20

  data_type: 'integer'
  is_nullable: 1

=head2 ser20

  data_type: 'integer'
  is_nullable: 1

=head2 oth20

  data_type: 'integer'
  is_nullable: 1

=head2 sf23

  data_type: 'integer'
  is_nullable: 1

=head2 mf23

  data_type: 'integer'
  is_nullable: 1

=head2 ret23

  data_type: 'integer'
  is_nullable: 1

=head2 ser23

  data_type: 'integer'
  is_nullable: 1

=head2 oth23

  data_type: 'integer'
  is_nullable: 1

=head2 sf25

  data_type: 'integer'
  is_nullable: 1

=head2 mf25

  data_type: 'integer'
  is_nullable: 1

=head2 ret25

  data_type: 'integer'
  is_nullable: 1

=head2 ser25

  data_type: 'integer'
  is_nullable: 1

=head2 oth25

  data_type: 'integer'
  is_nullable: 1

=head2 the_geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "sjv_network_nodes_gid_seq",
  },
  "n",
  { data_type => "integer", is_nullable => 1 },
  "x",
  { data_type => "double precision", is_nullable => 1 },
  "y",
  { data_type => "double precision", is_nullable => 1 },
  "taz_rgn",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "sf08",
  { data_type => "integer", is_nullable => 1 },
  "mf08",
  { data_type => "integer", is_nullable => 1 },
  "ret08",
  { data_type => "integer", is_nullable => 1 },
  "ser08",
  { data_type => "integer", is_nullable => 1 },
  "oth08",
  { data_type => "integer", is_nullable => 1 },
  "sf10",
  { data_type => "integer", is_nullable => 1 },
  "mf10",
  { data_type => "integer", is_nullable => 1 },
  "ret10",
  { data_type => "integer", is_nullable => 1 },
  "ser10",
  { data_type => "integer", is_nullable => 1 },
  "oth10",
  { data_type => "integer", is_nullable => 1 },
  "sf11",
  { data_type => "integer", is_nullable => 1 },
  "mf11",
  { data_type => "integer", is_nullable => 1 },
  "ret11",
  { data_type => "integer", is_nullable => 1 },
  "ser11",
  { data_type => "integer", is_nullable => 1 },
  "oth11",
  { data_type => "integer", is_nullable => 1 },
  "sf12",
  { data_type => "integer", is_nullable => 1 },
  "mf12",
  { data_type => "integer", is_nullable => 1 },
  "ret12",
  { data_type => "integer", is_nullable => 1 },
  "ser12",
  { data_type => "integer", is_nullable => 1 },
  "oth12",
  { data_type => "integer", is_nullable => 1 },
  "sf14",
  { data_type => "integer", is_nullable => 1 },
  "mf14",
  { data_type => "integer", is_nullable => 1 },
  "ret14",
  { data_type => "integer", is_nullable => 1 },
  "ser14",
  { data_type => "integer", is_nullable => 1 },
  "oth14",
  { data_type => "integer", is_nullable => 1 },
  "sf17",
  { data_type => "integer", is_nullable => 1 },
  "mf17",
  { data_type => "integer", is_nullable => 1 },
  "ret17",
  { data_type => "integer", is_nullable => 1 },
  "ser17",
  { data_type => "integer", is_nullable => 1 },
  "oth17",
  { data_type => "integer", is_nullable => 1 },
  "sf18",
  { data_type => "integer", is_nullable => 1 },
  "mf18",
  { data_type => "integer", is_nullable => 1 },
  "ret18",
  { data_type => "integer", is_nullable => 1 },
  "ser18",
  { data_type => "integer", is_nullable => 1 },
  "oth18",
  { data_type => "integer", is_nullable => 1 },
  "sf20",
  { data_type => "integer", is_nullable => 1 },
  "mf20",
  { data_type => "integer", is_nullable => 1 },
  "ret20",
  { data_type => "integer", is_nullable => 1 },
  "ser20",
  { data_type => "integer", is_nullable => 1 },
  "oth20",
  { data_type => "integer", is_nullable => 1 },
  "sf23",
  { data_type => "integer", is_nullable => 1 },
  "mf23",
  { data_type => "integer", is_nullable => 1 },
  "ret23",
  { data_type => "integer", is_nullable => 1 },
  "ser23",
  { data_type => "integer", is_nullable => 1 },
  "oth23",
  { data_type => "integer", is_nullable => 1 },
  "sf25",
  { data_type => "integer", is_nullable => 1 },
  "mf25",
  { data_type => "integer", is_nullable => 1 },
  "ret25",
  { data_type => "integer", is_nullable => 1 },
  "ser25",
  { data_type => "integer", is_nullable => 1 },
  "oth25",
  { data_type => "integer", is_nullable => 1 },
  "the_geom",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("gid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GxnkAbvVZVIlIQWLidIk8w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
