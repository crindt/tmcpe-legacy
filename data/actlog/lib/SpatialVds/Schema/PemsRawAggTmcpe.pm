package SpatialVds::Schema::PemsRawAggTmcpe;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::PemsRawAggTmcpe

=cut

__PACKAGE__->table("pems_raw_agg_tmcpe");

=head1 ACCESSORS

=head2 vds_id

  data_type: 'integer'
  is_nullable: 1

=head2 fivemin

  data_type: 'timestamp'
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

=head2 fivemin_tod

  data_type: 'time'
  is_nullable: 1
  size: 6

=cut

__PACKAGE__->add_columns(
  "vds_id",
  { data_type => "integer", is_nullable => 1 },
  "fivemin",
  { data_type => "timestamp", is_nullable => 1 },
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
  "fivemin_tod",
  { data_type => "time", is_nullable => 1, size => 6 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:urB5TDFPKV2fsrGiPSn2sQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
