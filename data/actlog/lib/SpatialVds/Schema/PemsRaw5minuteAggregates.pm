package SpatialVds::Schema::PemsRaw5minuteAggregates;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::PemsRaw5minuteAggregates

=cut

__PACKAGE__->table("pems_raw_5minute_aggregates");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 tod

  data_type: 'text'
  is_nullable: 1

=head2 dow

  data_type: 'text'
  is_nullable: 1

=head2 mon

  data_type: 'text'
  is_nullable: 1

=head2 intervals

  data_type: 'bigint'
  is_nullable: 1

=head2 nsum

  data_type: 'bigint'
  is_nullable: 1

=head2 oave

  data_type: 'numeric'
  is_nullable: 1

=head2 nlanes

  data_type: 'bigint[]'
  is_nullable: 1

=head2 olanes

  data_type: 'numeric[]'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "tod",
  { data_type => "text", is_nullable => 1 },
  "dow",
  { data_type => "text", is_nullable => 1 },
  "mon",
  { data_type => "text", is_nullable => 1 },
  "intervals",
  { data_type => "bigint", is_nullable => 1 },
  "nsum",
  { data_type => "bigint", is_nullable => 1 },
  "oave",
  { data_type => "numeric", is_nullable => 1 },
  "nlanes",
  { data_type => "bigint[]", is_nullable => 1 },
  "olanes",
  { data_type => "numeric[]", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4QorG2SMKpKBBwvlZVy/3A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
