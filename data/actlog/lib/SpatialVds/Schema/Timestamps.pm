package SpatialVds::Schema::Timestamps;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Timestamps

=cut

__PACKAGE__->table("timestamps");

=head1 ACCESSORS

=head2 ts

  data_type: 'timestamp'
  is_nullable: 0

=head2 fivemin

  data_type: 'time'
  is_nullable: 1
  size: 6

=head2 dow

  data_type: 'smallint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ts",
  { data_type => "timestamp", is_nullable => 0 },
  "fivemin",
  { data_type => "time", is_nullable => 1, size => 6 },
  "dow",
  { data_type => "smallint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("ts");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-05-09 10:35:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VlexYcey2DzsrjoK+Kw7aw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
