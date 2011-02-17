package SpatialVds::Schema::VdsStats;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsStats

=cut

__PACKAGE__->table("vds_stats");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 stats_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "stats_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("vds_id", "stats_id");

=head1 RELATIONS

=head2 stats_id

Type: belongs_to

Related object: L<SpatialVds::Schema::LoopStats>

=cut

__PACKAGE__->belongs_to(
  "stats_id",
  "SpatialVds::Schema::LoopStats",
  { id => "stats_id" },
);

=head2 vds_id

Type: belongs_to

Related object: L<SpatialVds::Schema::Vds>

=cut

__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::Vds", { id => "vds_id" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7HEmXgrUbL8Z94F+xpy9LQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
