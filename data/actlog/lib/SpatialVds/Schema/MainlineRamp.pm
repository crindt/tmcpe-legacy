package SpatialVds::Schema::MainlineRamp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::MainlineRamp

=cut

__PACKAGE__->table("mainline_ramp");

=head1 ACCESSORS

=head2 ml_vds_id

  data_type: 'integer'
  is_nullable: 0

=head2 r_vds_id

  data_type: 'integer'
  is_nullable: 0

=head2 distance

  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ml_vds_id",
  { data_type => "integer", is_nullable => 0 },
  "r_vds_id",
  { data_type => "integer", is_nullable => 0 },
  "distance",
  { data_type => "numeric", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("ml_vds_id", "r_vds_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-19 17:21:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jL+HGoN3Ja7NbqM5q2eRjw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
