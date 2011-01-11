package TMCPE::ActivityLog::Schema::CriticalEvents;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::CriticalEvents

=cut

__PACKAGE__->table("actlog.critical_events");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'actlog.critical_events_id_seq'

=head2 log_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 event_type

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 detail

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "actlog.critical_events_id_seq",
  },
  "log_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "event_type",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "detail",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 log_id

Type: belongs_to

Related object: L<TMCPE::ActivityLog::Schema::D12ActivityLog>

=cut

__PACKAGE__->belongs_to(
  "log_id",
  "TMCPE::ActivityLog::Schema::D12ActivityLog",
  { keyfield => "log_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:12:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DMg+XjG7ViLSGb3Pc+a70A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
