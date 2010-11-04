package SpatialVds::Schema::AccidentRiskResults;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::AccidentRiskResults

=cut

__PACKAGE__->table("accident_risk_results");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 estimate_time

  data_type: 'timestamp'
  is_nullable: 0

=head2 model_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 odds

  data_type: 'numeric'
  is_nullable: 0

=head2 vds_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "estimate_time",
  { data_type => "timestamp", is_nullable => 0 },
  "model_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "odds",
  { data_type => "numeric", is_nullable => 0 },
  "vds_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "accident_risk_results_vds_id_key",
  ["vds_id", "estimate_time", "model_name"],
);

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<SpatialVds::Schema::StatsIds>

=cut

__PACKAGE__->belongs_to("id", "SpatialVds::Schema::StatsIds", { id => "id" });

=head2 vds_id

Type: belongs_to

Related object: L<SpatialVds::Schema::Vds>

=cut

__PACKAGE__->belongs_to("vds_id", "SpatialVds::Schema::Vds", { id => "vds_id" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:T60jLHoT4IyYwMhnOyGjmA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
