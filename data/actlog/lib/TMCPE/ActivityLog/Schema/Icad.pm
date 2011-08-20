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

=head2 logid

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 logtime

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 80

=head2 logtype

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 240

=head2 location

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 240

=head2 area

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 240

=head2 thomasbrothers

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 80

=head2 tbxy

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 40

=head2 d12cad

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 80

=head2 d12cadalt

  data_type: 'varchar'
  default_value: NULL::character varying
  is_nullable: 1
  size: 80

=head2 log_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "keyfield",
  { data_type => "integer", is_nullable => 0 },
  "logid",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "logtime",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 80,
  },
  "logtype",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 240,
  },
  "location",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 240,
  },
  "area",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 240,
  },
  "thomasbrothers",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 80,
  },
  "tbxy",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 40,
  },
  "d12cad",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 80,
  },
  "d12cadalt",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 80,
  },
  "log_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("keyfield");

=head1 RELATIONS

=head2 icad_detail_icads

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::IcadDetail>

=cut

__PACKAGE__->has_many(
  "icad_detail_icads",
  "TMCPE::ActivityLog::Schema::IcadDetail",
  { "foreign.icad" => "self.keyfield" },
  {},
);

=head2 icad_detail_icad_ids

Type: has_many

Related object: L<TMCPE::ActivityLog::Schema::IcadDetail>

=cut

__PACKAGE__->has_many(
  "icad_detail_icad_ids",
  "TMCPE::ActivityLog::Schema::IcadDetail",
  { "foreign.icad_id" => "self.keyfield" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CqJpLQ5kaEEQi4fnv5jTGQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
