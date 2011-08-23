package TMCPE::Schema::BadSolutions;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::Schema::BadSolutions

=cut

__PACKAGE__->table("tmcpe.bad_solutions");

=head1 ACCESSORS

=head2 cad

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 start_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 cadid

  data_type: 'integer'
  is_nullable: 1

=head2 iiaid

  data_type: 'integer'
  is_nullable: 1

=head2 ifiaid

  data_type: 'integer'
  is_nullable: 1

=head2 solution_time_bounded

  data_type: 'boolean'
  is_nullable: 1

=head2 solution_space_bounded

  data_type: 'boolean'
  is_nullable: 1

=head2 bad_solution

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 d12delay

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "cad",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "start_time",
  { data_type => "timestamp", is_nullable => 1 },
  "cadid",
  { data_type => "integer", is_nullable => 1 },
  "iiaid",
  { data_type => "integer", is_nullable => 1 },
  "ifiaid",
  { data_type => "integer", is_nullable => 1 },
  "solution_time_bounded",
  { data_type => "boolean", is_nullable => 1 },
  "solution_space_bounded",
  { data_type => "boolean", is_nullable => 1 },
  "bad_solution",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "d12delay",
  { data_type => "double precision", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:19:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BROxT0F4xnIZB29Os8ATtw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
