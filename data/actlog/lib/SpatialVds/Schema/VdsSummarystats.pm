package SpatialVds::Schema::VdsSummarystats;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::VdsSummarystats

=cut

__PACKAGE__->table("vds_summarystats");

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

=head2 vds_id

Type: belongs_to

Related object: L<SpatialVds::Schema::Vds>

=cut

__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::Vds", { id => "vds_id" });

=head2 stats_id

Type: belongs_to

Related object: L<SpatialVds::Schema::LoopSummaryStats>

=cut

__PACKAGE__->belongs_to(
  "stats_id",
  "SpatialVds::Schema::LoopSummaryStats",
  { id => "stats_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gGcgFUA42Mq4y9mKTx/DPQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
