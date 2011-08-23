package SpatialVds::Schema::OctamLinks;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::OctamLinks

=cut

__PACKAGE__->table("octam_links");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'link_id_seq'

=head2 frnode

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 tonode

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 type

  data_type: 'smallint'
  is_nullable: 1

=head2 spd

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "link_id_seq",
  },
  "frnode",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "tonode",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "type",
  { data_type => "smallint", is_nullable => 1 },
  "spd",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 tonode

Type: belongs_to

Related object: L<SpatialVds::Schema::OctamNodes>

=cut

__PACKAGE__->belongs_to("tonode", "SpatialVds::Schema::OctamNodes", { id => "tonode" });

=head2 frnode

Type: belongs_to

Related object: L<SpatialVds::Schema::OctamNodes>

=cut

__PACKAGE__->belongs_to("frnode", "SpatialVds::Schema::OctamNodes", { id => "frnode" });


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-22 13:20:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hool840alk20k8HZspCAQQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
