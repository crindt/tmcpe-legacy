package SpatialVds::Schema::Vdstypes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Vdstypes

=cut

__PACKAGE__->table("vdstypes");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  is_nullable: 0
  size: 4

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", is_nullable => 0, size => 4 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 64 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M3uk8mh26/oGFq5IKTer2A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
