package SpatialVds::Schema::VdsDistrict;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsDistrict

=cut

__PACKAGE__->table("vds_district");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 0

=head2 district_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 0 },
  "district_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("vds_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+3ODlCjgTWF9qUcQe77m6w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
