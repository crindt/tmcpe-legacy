package SpatialVds::Schema::Vds30secondRawVersioned;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Vds30secondRawVersioned

=cut

__PACKAGE__->table("vds30second_raw_versioned");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_nullable: 0

=head2 version

  data_type: 'timestamp'
  is_nullable: 0

=head2 lanes

  data_type: 'integer'
  is_nullable: 0

=head2 n1

  data_type: 'integer'
  is_nullable: 0

=head2 n2

  data_type: 'integer'
  is_nullable: 0

=head2 n3

  data_type: 'integer'
  is_nullable: 0

=head2 n4

  data_type: 'integer'
  is_nullable: 0

=head2 n5

  data_type: 'integer'
  is_nullable: 0

=head2 n6

  data_type: 'integer'
  is_nullable: 0

=head2 n7

  data_type: 'integer'
  is_nullable: 0

=head2 n8

  data_type: 'integer'
  is_nullable: 0

=head2 o1

  data_type: 'real'
  is_nullable: 0

=head2 o2

  data_type: 'real'
  is_nullable: 0

=head2 o3

  data_type: 'real'
  is_nullable: 0

=head2 o4

  data_type: 'real'
  is_nullable: 0

=head2 o5

  data_type: 'real'
  is_nullable: 0

=head2 o6

  data_type: 'real'
  is_nullable: 0

=head2 o7

  data_type: 'real'
  is_nullable: 0

=head2 o8

  data_type: 'real'
  is_nullable: 0

=head2 s1

  data_type: 'real'
  is_nullable: 0

=head2 s2

  data_type: 'real'
  is_nullable: 0

=head2 s3

  data_type: 'real'
  is_nullable: 0

=head2 s4

  data_type: 'real'
  is_nullable: 0

=head2 s5

  data_type: 'real'
  is_nullable: 0

=head2 s6

  data_type: 'real'
  is_nullable: 0

=head2 s7

  data_type: 'real'
  is_nullable: 0

=head2 s8

  data_type: 'real'
  is_nullable: 0

=head2 segment_length

  data_type: 'real'
  is_nullable: 0

=head2 vdsid

  data_type: 'integer'
  is_nullable: 0

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 ts

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", is_nullable => 0 },
  "version",
  { data_type => "timestamp", is_nullable => 0 },
  "lanes",
  { data_type => "integer", is_nullable => 0 },
  "n1",
  { data_type => "integer", is_nullable => 0 },
  "n2",
  { data_type => "integer", is_nullable => 0 },
  "n3",
  { data_type => "integer", is_nullable => 0 },
  "n4",
  { data_type => "integer", is_nullable => 0 },
  "n5",
  { data_type => "integer", is_nullable => 0 },
  "n6",
  { data_type => "integer", is_nullable => 0 },
  "n7",
  { data_type => "integer", is_nullable => 0 },
  "n8",
  { data_type => "integer", is_nullable => 0 },
  "o1",
  { data_type => "real", is_nullable => 0 },
  "o2",
  { data_type => "real", is_nullable => 0 },
  "o3",
  { data_type => "real", is_nullable => 0 },
  "o4",
  { data_type => "real", is_nullable => 0 },
  "o5",
  { data_type => "real", is_nullable => 0 },
  "o6",
  { data_type => "real", is_nullable => 0 },
  "o7",
  { data_type => "real", is_nullable => 0 },
  "o8",
  { data_type => "real", is_nullable => 0 },
  "s1",
  { data_type => "real", is_nullable => 0 },
  "s2",
  { data_type => "real", is_nullable => 0 },
  "s3",
  { data_type => "real", is_nullable => 0 },
  "s4",
  { data_type => "real", is_nullable => 0 },
  "s5",
  { data_type => "real", is_nullable => 0 },
  "s6",
  { data_type => "real", is_nullable => 0 },
  "s7",
  { data_type => "real", is_nullable => 0 },
  "s8",
  { data_type => "real", is_nullable => 0 },
  "segment_length",
  { data_type => "real", is_nullable => 0 },
  "vdsid",
  { data_type => "integer", is_nullable => 0 },
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "ts",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z14lz6rBy/AHoH4tuXzFMQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
