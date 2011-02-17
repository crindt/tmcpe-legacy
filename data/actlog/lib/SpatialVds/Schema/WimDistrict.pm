package SpatialVds::Schema::WimDistrict;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimDistrict

=cut

__PACKAGE__->table("wim_district");

=head1 ACCESSORS

=head2 wim_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 district_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "wim_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "district_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 RELATIONS

=head2 wim_id

Type: belongs_to

Related object: L<SpatialVds::Schema::WimStations>

=cut

__PACKAGE__->belongs_to(
  "wim_id",
  "SpatialVds::Schema::WimStations",
  { site_no => "wim_id" },
);

=head2 district_id

Type: belongs_to

Related object: L<SpatialVds::Schema::Districts>

=cut

__PACKAGE__->belongs_to(
  "district_id",
  "SpatialVds::Schema::Districts",
  { id => "district_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AzrBTDpM50aW4hwG06sMMQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
