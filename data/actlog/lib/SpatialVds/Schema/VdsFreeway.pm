package SpatialVds::Schema::VdsFreeway;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsFreeway

=cut

__PACKAGE__->table("vds_freeway");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 freeway_id

  data_type: 'integer'
  is_nullable: 0

=head2 freeway_dir

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "freeway_id",
  { data_type => "integer", is_nullable => 0 },
  "freeway_dir",
  { data_type => "varchar", is_nullable => 1, size => 2 },
);
__PACKAGE__->set_primary_key("vds_id");

=head1 RELATIONS

=head2 vds_id

Type: belongs_to

Related object: L<SpatialVds::Schema::VdsIdAll>

=cut

__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::VdsIdAll", { id => "vds_id" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5JbDLcbkTd8+CdIr6b9Y6Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
