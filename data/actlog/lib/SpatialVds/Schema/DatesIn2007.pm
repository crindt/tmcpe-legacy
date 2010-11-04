package SpatialVds::Schema::DatesIn2007;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::DatesIn2007

=cut

__PACKAGE__->table("dates_in_2007");

=head1 ACCESSORS

=head2 dates

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns("dates", { data_type => "date", is_nullable => 1 });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wj/B03QiMhaxMzMjDyRnRQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
