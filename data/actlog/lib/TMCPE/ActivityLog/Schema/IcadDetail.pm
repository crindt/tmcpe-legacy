package TMCPE::ActivityLog::Schema::IcadDetail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::IcadDetail

=cut

__PACKAGE__->table("actlog.icad_detail");

=head1 ACCESSORS

=head2 keyfield

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'actlog.icad_detail_keyfield_seq'

=head2 icad

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 stamp

  data_type: 'timestamp'
  is_nullable: 0

=head2 detail

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 icad_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "keyfield",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "actlog.icad_detail_keyfield_seq",
  },
  "icad",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "stamp",
  { data_type => "timestamp", is_nullable => 0 },
  "detail",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "icad_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("keyfield");

=head1 RELATIONS

=head2 icad

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::Icad>

=cut

__PACKAGE__->belongs_to(
  "icad",
  "TMCPE::ActivityLog::Schema::Icad",
  { keyfield => "icad" },
);

=head2 icad_id

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::Icad>

=cut

__PACKAGE__->belongs_to(
  "icad_id",
  "TMCPE::ActivityLog::Schema::Icad",
  { keyfield => "icad_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:12:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vC6ePCBtI2cd/jTBL19HHA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
