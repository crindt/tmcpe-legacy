package OSM::Schema::CountiesFips;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::CountiesFips

=cut

__PACKAGE__->table("counties_fips");

=head1 ACCESSORS

=head2 fips

  data_type: 'varchar'
  is_nullable: 0
  size: 5

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "fips",
  { data_type => "varchar", is_nullable => 0, size => 5 },
  "name",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("fips");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3cBaU/2n+Wi/FP+GioWLaw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
