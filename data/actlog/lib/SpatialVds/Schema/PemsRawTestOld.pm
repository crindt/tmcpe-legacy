package SpatialVds::Schema::PemsRawTestOld;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::PemsRawTestOld

=cut

__PACKAGE__->table("pems_raw_test_old");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 ts

  data_type: 'timestamp'
  is_nullable: 1

=head2 n1

  data_type: 'smallint'
  is_nullable: 1

=head2 n2

  data_type: 'smallint'
  is_nullable: 1

=head2 n3

  data_type: 'smallint'
  is_nullable: 1

=head2 n4

  data_type: 'smallint'
  is_nullable: 1

=head2 n5

  data_type: 'smallint'
  is_nullable: 1

=head2 n6

  data_type: 'smallint'
  is_nullable: 1

=head2 n7

  data_type: 'smallint'
  is_nullable: 1

=head2 n8

  data_type: 'smallint'
  is_nullable: 1

=head2 o1

  data_type: 'numeric'
  is_nullable: 1
  size: [5,4]

=head2 o2

  data_type: 'numeric'
  is_nullable: 1
  size: [5,4]

=head2 o3

  data_type: 'numeric'
  is_nullable: 1
  size: [5,4]

=head2 o4

  data_type: 'numeric'
  is_nullable: 1
  size: [5,4]

=head2 o5

  data_type: 'numeric'
  is_nullable: 1
  size: [5,4]

=head2 o6

  data_type: 'numeric'
  is_nullable: 1
  size: [5,4]

=head2 o7

  data_type: 'numeric'
  is_nullable: 1
  size: [5,4]

=head2 o8

  data_type: 'numeric'
  is_nullable: 1
  size: [5,4]

=head2 s1

  data_type: 'numeric'
  is_nullable: 1
  size: [5,2]

=head2 s2

  data_type: 'numeric'
  is_nullable: 1
  size: [5,2]

=head2 s3

  data_type: 'numeric'
  is_nullable: 1
  size: [5,2]

=head2 s4

  data_type: 'numeric'
  is_nullable: 1
  size: [5,2]

=head2 s5

  data_type: 'numeric'
  is_nullable: 1
  size: [5,2]

=head2 s6

  data_type: 'numeric'
  is_nullable: 1
  size: [5,2]

=head2 s7

  data_type: 'numeric'
  is_nullable: 1
  size: [5,2]

=head2 s8

  data_type: 'numeric'
  is_nullable: 1
  size: [5,2]

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "ts",
  { data_type => "timestamp", is_nullable => 1 },
  "n1",
  { data_type => "smallint", is_nullable => 1 },
  "n2",
  { data_type => "smallint", is_nullable => 1 },
  "n3",
  { data_type => "smallint", is_nullable => 1 },
  "n4",
  { data_type => "smallint", is_nullable => 1 },
  "n5",
  { data_type => "smallint", is_nullable => 1 },
  "n6",
  { data_type => "smallint", is_nullable => 1 },
  "n7",
  { data_type => "smallint", is_nullable => 1 },
  "n8",
  { data_type => "smallint", is_nullable => 1 },
  "o1",
  { data_type => "numeric", is_nullable => 1, size => [5, 4] },
  "o2",
  { data_type => "numeric", is_nullable => 1, size => [5, 4] },
  "o3",
  { data_type => "numeric", is_nullable => 1, size => [5, 4] },
  "o4",
  { data_type => "numeric", is_nullable => 1, size => [5, 4] },
  "o5",
  { data_type => "numeric", is_nullable => 1, size => [5, 4] },
  "o6",
  { data_type => "numeric", is_nullable => 1, size => [5, 4] },
  "o7",
  { data_type => "numeric", is_nullable => 1, size => [5, 4] },
  "o8",
  { data_type => "numeric", is_nullable => 1, size => [5, 4] },
  "s1",
  { data_type => "numeric", is_nullable => 1, size => [5, 2] },
  "s2",
  { data_type => "numeric", is_nullable => 1, size => [5, 2] },
  "s3",
  { data_type => "numeric", is_nullable => 1, size => [5, 2] },
  "s4",
  { data_type => "numeric", is_nullable => 1, size => [5, 2] },
  "s5",
  { data_type => "numeric", is_nullable => 1, size => [5, 2] },
  "s6",
  { data_type => "numeric", is_nullable => 1, size => [5, 2] },
  "s7",
  { data_type => "numeric", is_nullable => 1, size => [5, 2] },
  "s8",
  { data_type => "numeric", is_nullable => 1, size => [5, 2] },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+tYez0vjcd0fx5OOxtzakw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
