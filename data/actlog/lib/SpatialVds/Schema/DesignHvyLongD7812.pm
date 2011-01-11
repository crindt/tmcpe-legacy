package SpatialVds::Schema::DesignHvyLongD7812;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::DesignHvyLongD7812

=cut

__PACKAGE__->table("design_hvy_long_d7812");

=head1 ACCESSORS

=head2 sampling_no

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'design_hvy_long_d7812_sampling_no_seq'

=head2 obs_no

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "sampling_no",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "design_hvy_long_d7812_sampling_no_seq",
  },
  "obs_no",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("sampling_no");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SfIrb5tx5TbJqGlwzLBlCA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
