package SpatialVds::Schema::WimCounty;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimCounty

=cut

__PACKAGE__->table("wim_county");

=head1 ACCESSORS

=head2 wim_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 county_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "wim_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "county_id",
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

=head2 county_id

Type: belongs_to

Related object: L<SpatialVds::Schema::Counties>

=cut

__PACKAGE__->belongs_to(
  "county_id",
  "SpatialVds::Schema::Counties",
  { id => "county_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DBeAK1ks8dEO3dcx9E/+KA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
