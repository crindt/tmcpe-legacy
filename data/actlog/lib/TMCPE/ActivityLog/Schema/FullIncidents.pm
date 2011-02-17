package TMCPE::ActivityLog::Schema::FullIncidents;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::ActivityLog::Schema::FullIncidents

=cut

__PACKAGE__->table("actlog.full_incidents");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 cad

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 start_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 first_call

  data_type: 'integer'
  is_nullable: 1

=head2 sigalert_begin

  data_type: 'integer'
  is_nullable: 1

=head2 sigalert_end

  data_type: 'integer'
  is_nullable: 1

=head2 location_vdsid

  data_type: 'integer'
  is_nullable: 1

=head2 event_type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 location_geom

  data_type: 'geometry'
  is_nullable: 1

=head2 verification

  data_type: 'integer'
  is_nullable: 1

=head2 lanes_clear

  data_type: 'integer'
  is_nullable: 1

=head2 incident_clear

  data_type: 'integer'
  is_nullable: 1

=head2 best_geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 1 },
  "cad",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "start_time",
  { data_type => "timestamp", is_nullable => 1 },
  "first_call",
  { data_type => "integer", is_nullable => 1 },
  "sigalert_begin",
  { data_type => "integer", is_nullable => 1 },
  "sigalert_end",
  { data_type => "integer", is_nullable => 1 },
  "location_vdsid",
  { data_type => "integer", is_nullable => 1 },
  "event_type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "location_geom",
  { data_type => "geometry", is_nullable => 1 },
  "verification",
  { data_type => "integer", is_nullable => 1 },
  "lanes_clear",
  { data_type => "integer", is_nullable => 1 },
  "incident_clear",
  { data_type => "integer", is_nullable => 1 },
  "best_geom",
  { data_type => "geometry", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:06:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e0FJ70VSR8Uu5aMSFzc9Qw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
