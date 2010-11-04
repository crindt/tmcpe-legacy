package SpatialVds::Schema::WimStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimStatus

=cut

__PACKAGE__->table("wim_status");

=head1 ACCESSORS

=head2 site_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ts

  data_type: 'date'
  is_nullable: 0

=head2 class_status

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 class_notes

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 weight_status

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 weight_notes

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ts",
  { data_type => "date", is_nullable => 0 },
  "class_status",
  {
    data_type      => "text",
    is_foreign_key => 1,
    is_nullable    => 0,
    original       => { data_type => "varchar" },
  },
  "class_notes",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "weight_status",
  {
    data_type      => "text",
    is_foreign_key => 1,
    is_nullable    => 0,
    original       => { data_type => "varchar" },
  },
  "weight_notes",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("site_no", "ts");

=head1 RELATIONS

=head2 site_no

Type: belongs_to

Related object: L<SpatialVds::Schema::WimStations>

=cut

__PACKAGE__->belongs_to(
  "site_no",
  "SpatialVds::Schema::WimStations",
  { site_no => "site_no" },
);

=head2 weight_status

Type: belongs_to

Related object: L<SpatialVds::Schema::WimStatusCodes>

=cut

__PACKAGE__->belongs_to(
  "weight_status",
  "SpatialVds::Schema::WimStatusCodes",
  { status => "weight_status" },
);

=head2 class_status

Type: belongs_to

Related object: L<SpatialVds::Schema::WimStatusCodes>

=cut

__PACKAGE__->belongs_to(
  "class_status",
  "SpatialVds::Schema::WimStatusCodes",
  { status => "class_status" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:q8pqrTYC1n76+2ktX+wV3w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
