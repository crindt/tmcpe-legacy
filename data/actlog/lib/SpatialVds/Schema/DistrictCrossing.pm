package SpatialVds::Schema::DistrictCrossing;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::DistrictCrossing

=cut

__PACKAGE__->table("district_crossing");

=head1 ACCESSORS

=head2 district_id

  data_type: 'integer'
  is_nullable: 0

=head2 crossing_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "district_id",
  { data_type => "integer", is_nullable => 0 },
  "crossing_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("district_id", "crossing_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:U8S6L93rhaYf3rrVmJbCTw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
