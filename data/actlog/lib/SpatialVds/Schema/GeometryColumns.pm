package SpatialVds::Schema::GeometryColumns;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::GeometryColumns

=cut

__PACKAGE__->table("geometry_columns");

=head1 ACCESSORS

=head2 f_table_catalog

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 f_table_schema

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 f_table_name

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 f_geometry_column

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 coord_dimension

  data_type: 'integer'
  is_nullable: 0

=head2 srid

  data_type: 'integer'
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=cut

__PACKAGE__->add_columns(
  "f_table_catalog",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "f_table_schema",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "f_table_name",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "f_geometry_column",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "coord_dimension",
  { data_type => "integer", is_nullable => 0 },
  "srid",
  { data_type => "integer", is_nullable => 0 },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 30 },
);
__PACKAGE__->set_primary_key(
  "f_table_catalog",
  "f_table_schema",
  "f_table_name",
  "f_geometry_column",
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7Ic3zqsvZnkXv2Uw5+V1Sw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
