package SpatialVds::Schema::VdsVdstype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsVdstype

=cut

__PACKAGE__->table("vds_vdstype");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 0

=head2 type_id

  data_type: 'varchar'
  is_nullable: 0
  size: 4

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 0 },
  "type_id",
  { data_type => "varchar", is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("vds_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aDWlANIHlM5dBMKy9cHMvg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
