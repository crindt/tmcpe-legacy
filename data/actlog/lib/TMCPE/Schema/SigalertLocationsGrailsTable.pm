package TMCPE::Schema::SigalertLocationsGrailsTable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

TMCPE::Schema::SigalertLocationsGrailsTable

=cut

__PACKAGE__->table("tmcpe.sigalert_locations_grails_table");

=head1 ACCESSORS

=head2 cad

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 stamptime

  data_type: 'time'
  is_nullable: 0

=head2 stampdate

  data_type: 'timestamp'
  is_nullable: 0

=head2 memo

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 location

  data_type: 'geometry'
  is_nullable: 0

=head2 analyses_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 vdsid

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "cad",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "stamptime",
  { data_type => "time", is_nullable => 0 },
  "stampdate",
  { data_type => "timestamp", is_nullable => 0 },
  "memo",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "location",
  { data_type => "geometry", is_nullable => 0 },
  "analyses_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "vdsid",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("cad");

=head1 RELATIONS

=head2 analyses_id

Type: belongs_to

Related object: L<TMCPE::Schema::IncidentImpactAnalysis>

=cut

__PACKAGE__->belongs_to(
  "analyses_id",
  "TMCPE::Schema::IncidentImpactAnalysis",
  { id => "analyses_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:12:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YtuCdytd+xZbDcCBXg4vtQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
