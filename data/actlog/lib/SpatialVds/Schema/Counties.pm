package SpatialVds::Schema::Counties;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Counties

=cut

__PACKAGE__->table("counties");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'counties_id_seq'

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
    sequence          => "counties_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 wim_counties

Type: has_many

Related object: L<SpatialVds::Schema::WimCounty>

=cut

__PACKAGE__->has_many(
  "wim_counties",
  "SpatialVds::Schema::WimCounty",
  { "foreign.county_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l/+XxYkaDCA5sPhao+pV6A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
