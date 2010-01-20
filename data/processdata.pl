#!/usr/bin/perl 

while(<STDIN>) 
{
    chomp( $_ );
    my (@data) = split( /,/, $_ );
    my $sz = scalar( @data );
    my $add = 4+(10*3)-$sz;
    print join( ",",
		$_,
		map { "NULL" } ( 1..$add ) )."\n";
}
