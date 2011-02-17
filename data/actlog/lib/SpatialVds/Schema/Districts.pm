package SpatialVds::Schema::Districts;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Districts

=cut

__PACKAGE__->table("districts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'districts_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "districts_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 wim_districts

Type: has_many

Related object: L<SpatialVds::Schema::WimDistrict>

=cut

__PACKAGE__->has_many(
  "wim_districts",
  "SpatialVds::Schema::WimDistrict",
  { "foreign.district_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5j2h3E4BJE8/LRKcy22AKQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
