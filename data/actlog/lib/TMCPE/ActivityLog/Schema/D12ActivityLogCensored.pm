package TMCPE::ActivityLog::Schema::D12ActivityLogCensored;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::D12ActivityLogCensored

=cut

__PACKAGE__->table("actlog.d12_activity_log_censored");

=head1 ACCESSORS

=head2 keyfield

  data_type: 'integer'
  is_nullable: 1

=head2 cad

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 unitin

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 unitout

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 via

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 op

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 device_number

  data_type: 'integer'
  is_nullable: 1

=head2 device_extra

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=head2 device_direction

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 device_fwy

  data_type: 'integer'
  is_nullable: 1

=head2 device_name

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 activitysubject

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 memo

  data_type: 'text'
  is_nullable: 1

=head2 stamp

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", is_nullable => 1 },
  "cad",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "unitin",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "unitout",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "via",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "op",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "device_number",
  { data_type => "integer", is_nullable => 1 },
  "device_extra",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "device_direction",
  { data_type => "char", is_nullable => 1, size => 1 },
  "device_fwy",
  { data_type => "integer", is_nullable => 1 },
  "device_name",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "activitysubject",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "memo",
  { data_type => "text", is_nullable => 1 },
  "stamp",
  { data_type => "timestamp", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:24:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1GnD6EX4ilKuIOjjQ8bRzg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
