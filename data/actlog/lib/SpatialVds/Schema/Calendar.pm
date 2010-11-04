package SpatialVds::Schema::Calendar;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::Calendar

=cut

__PACKAGE__->table("calendar");

=head1 ACCESSORS

=head2 calendar_key

  data_type: 'date'
  is_nullable: 0

=head2 dow

  data_type: 'smallint'
  is_nullable: 1

=head2 dom

  data_type: 'smallint'
  is_nullable: 1

=head2 year

  data_type: 'smallint'
  is_nullable: 1

=head2 holiday

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "calendar_key",
  { data_type => "date", is_nullable => 0 },
  "dow",
  { data_type => "smallint", is_nullable => 1 },
  "dom",
  { data_type => "smallint", is_nullable => 1 },
  "year",
  { data_type => "smallint", is_nullable => 1 },
  "holiday",
  { data_type => "boolean", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("calendar_key");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E9fMvW9oh2OvDkLCS791yg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
