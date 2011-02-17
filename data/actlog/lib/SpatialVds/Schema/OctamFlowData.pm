package SpatialVds::Schema::OctamFlowData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamFlowData

=cut

__PACKAGE__->table("octam_flow_data");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 ab_daily_volume

  data_type: 'double precision'
  is_nullable: 1

=head2 ba_daily_volume

  data_type: 'double precision'
  is_nullable: 1

=head2 tot_daily_volume

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "ab_daily_volume",
  { data_type => "double precision", is_nullable => 1 },
  "ba_daily_volume",
  { data_type => "double precision", is_nullable => 1 },
  "tot_daily_volume",
  { data_type => "double precision", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ANPh7NtRWaue/KqDpzQKWw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
