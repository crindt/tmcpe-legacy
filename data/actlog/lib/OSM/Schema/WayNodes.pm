package OSM::Schema::WayNodes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::WayNodes

=cut

__PACKAGE__->table("way_nodes");

=head1 ACCESSORS

=head2 way_id

  data_type: 'bigint'
  is_nullable: 0

=head2 node_id

  data_type: 'bigint'
  is_nullable: 0

=head2 sequence_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "way_id",
  { data_type => "bigint", is_nullable => 0 },
  "node_id",
  { data_type => "bigint", is_nullable => 0 },
  "sequence_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("way_id", "sequence_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:13:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t1wtGeGmFZhZIyrkpoAgRA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
