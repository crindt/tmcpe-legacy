package OSM::Schema::GeographyColumns;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::GeographyColumns

=cut

__PACKAGE__->table("geography_columns");

=head1 ACCESSORS

=head2 f_table_catalog

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 f_table_schema

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 f_table_name

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 f_geography_column

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 coord_dimension

  data_type: 'integer'
  is_nullable: 1

=head2 srid

  data_type: 'integer'
  is_nullable: 1

=head2 type

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "f_table_catalog",
  { data_type => "name", is_nullable => 1, size => 64 },
  "f_table_schema",
  { data_type => "name", is_nullable => 1, size => 64 },
  "f_table_name",
  { data_type => "name", is_nullable => 1, size => 64 },
  "f_geography_column",
  { data_type => "name", is_nullable => 1, size => 64 },
  "coord_dimension",
  { data_type => "integer", is_nullable => 1 },
  "srid",
  { data_type => "integer", is_nullable => 1 },
  "type",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Dq4ZvgVxnJ3yZNUXn4k34w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
