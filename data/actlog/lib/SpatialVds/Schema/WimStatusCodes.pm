package SpatialVds::Schema::WimStatusCodes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimStatusCodes

=cut

__PACKAGE__->table("wim_status_codes");

=head1 ACCESSORS

=head2 status

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 description

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "status",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "description",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("status");

=head1 RELATIONS

=head2 wim_status_weight_statuses

Type: has_many

Related object: L<SpatialVds::Schema::WimStatus>

=cut

__PACKAGE__->has_many(
  "wim_status_weight_statuses",
  "SpatialVds::Schema::WimStatus",
  { "foreign.weight_status" => "self.status" },
  {},
);

=head2 wim_status_class_statuses

Type: has_many

Related object: L<SpatialVds::Schema::WimStatus>

=cut

__PACKAGE__->has_many(
  "wim_status_class_statuses",
  "SpatialVds::Schema::WimStatus",
  { "foreign.class_status" => "self.status" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nOaR1mF29G2hJfNcz8FwPA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
