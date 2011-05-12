package TMCPE::ActivityLog::Schema::CtAlTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::CtAlTransaction

=cut

__PACKAGE__->table("actlog.ct_al_transaction");

=head1 ACCESSORS

=head2 keyfield

  data_type: 'integer'
  is_nullable: 0

=head2 activitysubject

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 cad

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 device_direction

  data_type: 'char'
  is_nullable: 0
  size: 1

=head2 device_extra

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 device_fwy

  data_type: 'integer'
  is_nullable: 0

=head2 device_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 device_number

  data_type: 'integer'
  is_nullable: 0

=head2 memo

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 op

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 stampdate

  data_type: 'timestamp'
  is_nullable: 0

=head2 stamptime

  data_type: 'time'
  is_nullable: 0

=head2 status

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 unitin

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 unitout

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 via

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", is_nullable => 0 },
  "activitysubject",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "cad",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "device_direction",
  { data_type => "char", is_nullable => 0, size => 1 },
  "device_extra",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "device_fwy",
  { data_type => "integer", is_nullable => 0 },
  "device_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "device_number",
  { data_type => "integer", is_nullable => 0 },
  "memo",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "op",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "stampdate",
  { data_type => "timestamp", is_nullable => 0 },
  "stamptime",
  { data_type => "time", is_nullable => 0 },
  "status",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "unitin",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "unitout",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "via",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("keyfield");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:34:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S5SNQmp4jcqUBz69bzuHNA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
