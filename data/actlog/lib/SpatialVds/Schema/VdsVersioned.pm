package SpatialVds::Schema::VdsVersioned;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsVersioned

=cut

__PACKAGE__->table("vds_versioned");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 lanes

  data_type: 'integer'
  is_nullable: 0

=head2 segment_length

  data_type: 'numeric'
  is_nullable: 1

=head2 version

  data_type: 'date'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "lanes",
  { data_type => "integer", is_nullable => 0 },
  "segment_length",
  { data_type => "numeric", is_nullable => 1 },
  "version",
  { data_type => "date", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id", "version");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<SpatialVds::Schema::VdsIdAll>

=cut

__PACKAGE__->belongs_to("id", "SpatialVds::Schema::VdsIdAll", { id => "id" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:movovlDBB/upO+zcxNAVsA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
