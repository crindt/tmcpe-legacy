package OSM::Schema::SchemaInfo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OSM::Schema::SchemaInfo

=cut

__PACKAGE__->table("schema_info");

=head1 ACCESSORS

=head2 version

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("version", { data_type => "integer", is_nullable => 0 });
__PACKAGE__->set_primary_key("version");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-03 22:25:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2dYp8UV6rr2aDNyqXPz+wg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
