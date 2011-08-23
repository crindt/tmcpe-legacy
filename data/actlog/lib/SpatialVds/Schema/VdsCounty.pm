package SpatialVds::Schema::VdsCounty;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsCounty

=cut

__PACKAGE__->table("vds_county");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 0

=head2 county_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 0 },
  "county_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("vds_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oTySU7TgBBp2aObA5kQ3WA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
