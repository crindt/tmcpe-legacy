package TMCPE::ActivityLog::Schema::Icad;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::Icad

=cut

__PACKAGE__->table("actlog.icad");

=head1 ACCESSORS

=head2 keyfield

  data_type: 'integer'
  is_nullable: 0

=head2 d12cad

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 d12cadalt

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 location

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 log_id

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 logtime

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 logtype

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 tbxy

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 thomasbrothers

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", is_nullable => 0 },
  "d12cad",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "d12cadalt",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "location",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "log_id",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "logtime",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "logtype",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "tbxy",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "thomasbrothers",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("keyfield");

=head1 RELATIONS

=head2 icad_details

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::IcadDetail>

=cut

__PACKAGE__->has_many(
  "icad_details",
  "TMCPE::ActivityLog::Schema::IcadDetail",
  { "foreign.icad_id" => "self.keyfield" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:19:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/3hta5MQajD1C3H/+l3Tog


# You can replace this text with custom content, and it will be preserved on regeneration
1;
