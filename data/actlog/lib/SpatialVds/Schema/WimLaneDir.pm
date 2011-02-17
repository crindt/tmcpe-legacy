package SpatialVds::Schema::WimLaneDir;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SpatialVds::Schema::WimLaneDir

=cut

__PACKAGE__->table("wim_lane_dir");

=head1 ACCESSORS

=head2 site_no

  data_type: 'integer'
  is_nullable: 0

=head2 direction

  data_type: 'varchar'
  is_nullable: 0
  size: 1

=head2 lane_no

  data_type: 'integer'
  is_nullable: 0

=head2 wim_lane_no

  data_type: 'integer'
  is_nullable: 1

=head2 facility

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "site_no",
  { data_type => "integer", is_nullable => 0 },
  "direction",
  { data_type => "varchar", is_nullable => 0, size => 1 },
  "lane_no",
  { data_type => "integer", is_nullable => 0 },
  "wim_lane_no",
  { data_type => "integer", is_nullable => 1 },
  "facility",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("site_no", "direction", "lane_no");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 14:07:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:txQ5YnSPF/As7+rzaTv9fQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
