package OSM::Schema::SpatialRefSys;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::SpatialRefSys

=cut

__PACKAGE__->table("spatial_ref_sys");

=head1 ACCESSORS

=head2 srid

  data_type: 'integer'
  is_nullable: 0

=head2 auth_name

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 auth_srid

  data_type: 'integer'
  is_nullable: 1

=head2 srtext

  data_type: 'varchar'
  is_nullable: 1
  size: 2048

=head2 proj4text

  data_type: 'varchar'
  is_nullable: 1
  size: 2048

=cut

__PACKAGE__->add_columns(
  "srid",
  { data_type => "integer", is_nullable => 0 },
  "auth_name",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "auth_srid",
  { data_type => "integer", is_nullable => 1 },
  "srtext",
  { data_type => "varchar", is_nullable => 1, size => 2048 },
  "proj4text",
  { data_type => "varchar", is_nullable => 1, size => 2048 },
);
__PACKAGE__->set_primary_key("srid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2WpiZ3z7zC8SPP2zqt7PCQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
