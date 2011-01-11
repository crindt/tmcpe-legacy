package SpatialVds::Schema::VdsCity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsCity

=cut

__PACKAGE__->table("vds_city");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 0

=head2 city_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 0 },
  "city_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("vds_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cVQIv1JqrprXlqoJFZfVgg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
