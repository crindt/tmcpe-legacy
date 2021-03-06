package OSM::Schema::Nodes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::Nodes

=cut

__PACKAGE__->table("nodes");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_nullable: 0

=head2 version

  data_type: 'integer'
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 0

=head2 tstamp

  data_type: 'timestamp'
  is_nullable: 0

=head2 changeset_id

  data_type: 'bigint'
  is_nullable: 0

=head2 geom

  data_type: 'geometry'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", is_nullable => 0 },
  "version",
  { data_type => "integer", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 0 },
  "tstamp",
  { data_type => "timestamp", is_nullable => 0 },
  "changeset_id",
  { data_type => "bigint", is_nullable => 0 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RiwW9MJxynX51rYrOjB/dQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
