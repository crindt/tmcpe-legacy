package SpatialVds::Schema::FfConnectors;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::FfConnectors

=cut

__PACKAGE__->table("ff_connectors");

=head1 ACCESSORS

=head2 reffrom

  data_type: 'integer'
  is_nullable: 1

=head2 dirfrom

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 refto

  data_type: 'integer'
  is_nullable: 1

=head2 dirto

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 components

  data_type: 'integer[]'
  is_nullable: 0

=head2 next

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "reffrom",
  { data_type => "integer", is_nullable => 1 },
  "dirfrom",
  { data_type => "char", is_nullable => 1, size => 1 },
  "refto",
  { data_type => "integer", is_nullable => 1 },
  "dirto",
  { data_type => "char", is_nullable => 1, size => 1 },
  "components",
  { data_type => "integer[]", is_nullable => 0 },
  "next",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("components");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bxIH++cUM0s4M3GkdxLfYA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
