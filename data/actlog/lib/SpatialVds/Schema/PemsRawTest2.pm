package SpatialVds::Schema::PemsRawTest2;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::PemsRawTest2

=cut

__PACKAGE__->table("pems_raw_test2");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 ts

  data_type: 'timestamp'
  is_nullable: 1

=head2 n1

  data_type: 'integer'
  is_nullable: 1

=head2 n2

  data_type: 'integer'
  is_nullable: 1

=head2 n3

  data_type: 'integer'
  is_nullable: 1

=head2 n4

  data_type: 'integer'
  is_nullable: 1

=head2 n5

  data_type: 'integer'
  is_nullable: 1

=head2 n6

  data_type: 'integer'
  is_nullable: 1

=head2 n7

  data_type: 'integer'
  is_nullable: 1

=head2 n8

  data_type: 'integer'
  is_nullable: 1

=head2 o1

  data_type: 'numeric'
  is_nullable: 1

=head2 o2

  data_type: 'numeric'
  is_nullable: 1

=head2 o3

  data_type: 'numeric'
  is_nullable: 1

=head2 o4

  data_type: 'numeric'
  is_nullable: 1

=head2 o5

  data_type: 'numeric'
  is_nullable: 1

=head2 o6

  data_type: 'numeric'
  is_nullable: 1

=head2 o7

  data_type: 'numeric'
  is_nullable: 1

=head2 o8

  data_type: 'numeric'
  is_nullable: 1

=head2 s1

  data_type: 'numeric'
  is_nullable: 1

=head2 s2

  data_type: 'numeric'
  is_nullable: 1

=head2 s3

  data_type: 'numeric'
  is_nullable: 1

=head2 s4

  data_type: 'numeric'
  is_nullable: 1

=head2 s5

  data_type: 'numeric'
  is_nullable: 1

=head2 s6

  data_type: 'numeric'
  is_nullable: 1

=head2 s7

  data_type: 'numeric'
  is_nullable: 1

=head2 s8

  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "ts",
  { data_type => "timestamp", is_nullable => 1 },
  "n1",
  { data_type => "integer", is_nullable => 1 },
  "n2",
  { data_type => "integer", is_nullable => 1 },
  "n3",
  { data_type => "integer", is_nullable => 1 },
  "n4",
  { data_type => "integer", is_nullable => 1 },
  "n5",
  { data_type => "integer", is_nullable => 1 },
  "n6",
  { data_type => "integer", is_nullable => 1 },
  "n7",
  { data_type => "integer", is_nullable => 1 },
  "n8",
  { data_type => "integer", is_nullable => 1 },
  "o1",
  { data_type => "numeric", is_nullable => 1 },
  "o2",
  { data_type => "numeric", is_nullable => 1 },
  "o3",
  { data_type => "numeric", is_nullable => 1 },
  "o4",
  { data_type => "numeric", is_nullable => 1 },
  "o5",
  { data_type => "numeric", is_nullable => 1 },
  "o6",
  { data_type => "numeric", is_nullable => 1 },
  "o7",
  { data_type => "numeric", is_nullable => 1 },
  "o8",
  { data_type => "numeric", is_nullable => 1 },
  "s1",
  { data_type => "numeric", is_nullable => 1 },
  "s2",
  { data_type => "numeric", is_nullable => 1 },
  "s3",
  { data_type => "numeric", is_nullable => 1 },
  "s4",
  { data_type => "numeric", is_nullable => 1 },
  "s5",
  { data_type => "numeric", is_nullable => 1 },
  "s6",
  { data_type => "numeric", is_nullable => 1 },
  "s7",
  { data_type => "numeric", is_nullable => 1 },
  "s8",
  { data_type => "numeric", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FTq+KgVGQGbFGP6Xw0tPbA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
