#!/usr/bin/perl -I./lib

use strict;
use IO::All;
use DBI;
use Getopt::Long;
use JSON;
use Geo::WKT;

use Date::Parse;
use Date::Calc qw( Delta_DHMS Time_to_Date Day_of_Week Day_of_Week_to_Text Mktime Localtime Add_Delta_DHMS );
use Date::Format;

use SpatialVds::Schema;
use TMCPE::Schema;
use CT_AL::Schema;

use warnings;
use English qw(-no_match_vars);
use Readonly;

my $spatialvds_db;
my $tmcpe_db;
my $actlog_db;

my $datefrom;
my $dateto;

GetOptions ("datefrom=s" => \$datefrom,
	    "dateto=s" => \$dateto
	    ) || die "usage: analyze-incident.pl [--datefrom=<date>] [--dateto=<date>] [incident]\n";


# The purpose of this script is to pull as much information 
# about incidents from the activity logs as we can

# First step: pull metadata for incident.
$actlog_db = CT_AL::Schema->connect(
    "dbi:Pg:dbname=tmcpe;host=localhost",
    "postgres", undef,
    { AutoCommit => 1, db_schema => 'actlog' },
    );

$tmcpe_db = TMCPE::Schema->connect(
    "dbi:Pg:dbname=tmcpe;host=localhost",
    "postgres", undef,
    { AutoCommit => 1, db_schema => 'tmcpe' },
    );


my $incrs;
if ( $ARGV[0] ) {
    $incrs = $tmcpe_db->resultset('IncidentLocationsGrailsTable')->search( 
	{ cad=>$ARGV[0] } 
	);
} else {
    my $condition = {};

    my $datecond;
    $datecond->{'>='} = $datefrom if $datefrom;
    $datecond->{'<='} = $dateto   if $dateto;




    $condition->{stampdate} = $datecond if $datecond;
    $condition->{cad} = { '-in' -> [ @ARGV ] } if $#ARGV>=0;
    
    $incrs = $tmcpe_db->resultset('IncidentLocationsGrailsTable')->search(
	$condition
	);
}

while ( my $incdata = $incrs->next ) 
{
    print join ( " ",
		 "========================================",
		 "\nANALYZING",
		 $incdata->cad,
		 "@",
		 $incdata->vdsid,
		 join( "", "[", $incdata->xs, "]" 
		 )
	)."\n";
    
    # OK, pull raw data
    my @logdetail = $actlog_db->resultset('Al')->search( 
	{ cad => $incdata->cad },
	{ order_by => 'ts asc' }
	) -> all();

    my $unit;
    my $cctv;
    my $mio;
    my $hq;
    my $oth;
    my $firstcall;
    my $openincident;
    my $sigalert;

    foreach my $det ( @logdetail ) {
	print join( "",
		    "\t",
		    join ( " : ",
			   $det->ts,
			   $det->unitin,
			   $det->status,
			   $det->activitysubject,
			   $det->memo
			   ),
		    "\n" );
	
	if ( $det->unitin =~ /^\d+-/ ) {
	    push @{$unit->{$det->unitin}}, $det;
	};

	if ( $det->unitin =~ /CCTV/ 
	     || $det->memo =~ /PER\s+CCTV/
	     || $det->memo =~ /ON\s+CCTV/
	     ) {
	    push @{$cctv}, $det;
	}

	push @{$firstcall}, $det if ( $det->status eq 'FIRST CALL' || $det->activitysubject eq 'OPEN INCIDENT' );

	push @{$sigalert}, $det if ( $det->activitysubject =~ /SIGALERT/i 
#				     || $det->memo =~ /FAXED\s+SIGALERT/i
				     || $det->memo =~ /SIGALERT.*ISSUE/i
				     || $det->memo =~ /SIGALERT.*CANCEL/i
				     || $det->memo =~ /SIGALERT.*1022/i
	    );
    }

    my $start;

    if ( $firstcall ) {
	print "FIRST CALL:\n";
	foreach my $fc ( @{$firstcall} ) {
	    print join( "",
			"\t\t",
			join( " :: ",
			      $fc->ts,
			      $fc->status,
			      $fc->activitysubject,
			      $fc->memo ),
			"\n"
		);
	}
	if ( $logdetail[0]->ts ne $firstcall->[0]->ts ) {
	    print "\t***FIRST CALL AFTER FIRST LOG ENTRY\n";
	}
	if ( !$start || $firstcall->[0]->ts lt $start->ts ) 
	{
	    $start = $firstcall->[0];
	}
    }

    if ( $start ) {
	print "\t\t===ASSUMED START IS " . $start->ts . "\n";
	my $locdata = parse_al_memo( $start->memo );
	my $xs = process_xs( $locdata->{xs} );

	if ( $locdata->{f1dir} && $locdata->{f1fac} ) {
	    print join( "",
			"\t\t   => ",
			$locdata->{f1fac},
			"-",
			$locdata->{f1dir},
			" ",
			$locdata->{relloc},
			" ",
			join( " ",
			      grep { $_ } (
				  $xs->[1],
				  $xs->[0],
				  $xs->[2]
				  )
			),
			"\n"
		);
	}
	1;
    } else {
	print "\t\t***!!!***NO START FOUND***!!!***\n";
    }


    if ( $sigalert ) {
	my @sa = @{$sigalert};

	# CHECK FOR VALIDITY
	my $valid = 0;
	my $incstart;
	my $incend;
	if ( ( $sa[0]->activitysubject eq 'SIGALERT BEGIN'
	     || $sa[0]->memo =~ /SIGALERT.*ISSUE/ 
#	     || $sa[0]->memo =~ /FAXED\s+SIGALERT/ 
	     )
	     && ($sa[$#sa]->activitysubject eq 'SIGALERT END' 
	     || $sa[$#sa]->memo =~ /SIGALERT.*CANCEL/
	     || $sa[$#sa]->memo =~ /SIGALERT.*1022/)
	    ) {
	
	    my @tt = Localtime(str2time( join( ' ', $sa[0]->stampdate, $sa[0]->stamptime ) ));
	    $incstart = Mktime(@tt[0..5]);
	    @tt = Localtime(str2time( join( ' ', $sa[$#sa]->stampdate, $sa[$#sa]->stamptime ) ));
	    $incend   = Mktime(@tt[0..5]);
	    my @dur = Delta_DHMS( Time_to_Date( $incstart ), Time_to_Date( $incend ) );
	    my $dirstr = sprintf( "%dd:%2.2d:%2.2d:%2.2d", @dur );
	    
	    print "THIS INCIDENT IS A SIGALERT WITH DURATION: $dirstr\n";
	    $valid = 1;
	} else {
	    print "THIS INCIDENT IS A SIGALERT WITH NONSTANDARD REPORTING (NO BEGIN/END)\n";
	}

	my $estdur;
	foreach my $s ( @{$sigalert} ) {
	    print join( "",
			"\t\t",
			join( " :: ",
			      $s->ts,
			      $s->status,
			      $s->activitysubject,
			      $s->memo ),
			"\n"
		);

	    if ( $valid ) {
		my ($amt, $unit) = ( $s->memo =~ /FOR\s+(\d+)\s+([HM]\w+)/ );
		if ( $amt && $unit && $s->activitysubject =~ /SIGALERT BEGIN/i) {
		    $_ = $unit;
		    $estdur = $amt+0;
		    ( /HR/ || /HOUR/ || /HRS/ ) && do { $estdur *= 60 };
		} else {
#		print join( "",
#			    "\t*** ESTIMATED TIME WAS UNKNOWN\n" );
		}
	    }
	}
	# compute how much initial estimate was off
	if ( $estdur ) {
	    my @tt = Localtime(str2time( join( ' ', $sa[0]->stampdate, $sa[0]->stamptime ) ));
	    my @estend = Add_Delta_DHMS( Time_to_Date( $incstart), 0, 0, $estdur, 0 );
	    my @esterr = Delta_DHMS( Time_to_Date( $incend ), @estend );
	    my $neg = 0;

	    # see if the estimate was short or long
	    map { if ( $_ < 0 ) { $neg=1 } } @esterr;

	    print join( "",
			"\t\t*** INITIALLY ESTIMATED TIME WAS ",
			$estdur,
			" MINUTES\n" );
	    print join( "",
			"\t\t*** INITIAL SIGALERT ESTIMATE ",
			($neg ? " UNDERESTIMATED" : " OVERESTIMATED"),
			" DURATION BY ",
			sprintf( "%dd:%2.2d:%2.2d:%2.2d", map { if ( $_ < 0 ) { -$_ } else { $_ } } @esterr ),
			"\n" );
	}
	
    }


    if ( $unit ) {
	print "UNITS:\n";
	foreach my $u ( keys %{$unit} ) {
	    my @entries = @{$unit->{$u}};
	    print join( " ",
			"\tUNIT ",
			$u,
			"has ",
			scalar( @entries ),
			"entries",
			"\n" );
	    foreach my $uu ( @entries ) {
		print join( "",
			    "\t\t",
			    join( " :: ",
				  $uu->ts,
				  $uu->unitin,
				  $uu->status,
				  $uu->memo ),
			    "\n"
		    )
	    }
	}
    }

    my @cctvver;
    my @cctvvis;
    my @goodcctv;
    if ( $cctv && scalar( @{$cctv} ) ) {
	print "CCTV:\n";
	foreach my $cc ( @{$cctv} ) {
	    print join( "",
			"\t\t",
			join( " :: ",
			      $cc->ts,
			      $cc->status,
			      $cc->activitysubject,
			      $cc->memo ),
			"\n"
		);

	    # do some analysis here:
	    # INCIDENT VERIFICATION
	    if ( $cc->activitysubject eq 'VERIFICATION' ) {
		push @cctvver, $cc;
	    }
	    if ( $cc->memo =~ /VISUAL/i ) {
		push @cctvvis, $cc;
	    }
	    if ( not ( $cc->status =~ /FAIL/ ) 
		 && not ( $cc->status =~ /PROB/ ) ) {
		push @goodcctv, $cc;
	    }
	}
	if ( @goodcctv ) {
	    print join( "",
			"\t***EARLIEST CCTV WAS ",
			$goodcctv[0]->ts,
			"\n"
		);
	}
	my $verdiff;
	if ( @cctvver ) {
	    print join( "",
			"\t***EARLIEST CCTV VERIFICATION WAS ",
			$cctvver[0]->ts,
			"\n"
		);
	    if ( @goodcctv && $cctvver[0]->ts ne $goodcctv[0]->ts ) {
		$verdiff = 1;
	    }
	}
	my $visdiff;
	if ( @cctvvis ) {
	    print join( "",
			"\t***EARLIEST CCTV VISUAL WAS ",
			$cctvvis[0]->ts,
			"\n"
		);
	    if ( @goodcctv && $cctvvis[0]->ts ne $goodcctv[0]->ts ) {
		$visdiff = 1;
	    }
	}
	if ( @cctvver && @cctvvis && ( $cctvver[0]->ts ne $cctvvis[0]->ts ) ) {
	    print join( "",
			"\t***EARLIEST VERIFICATION AND VISUAL DIFFER!!",
			"\n"
		);
	}
	if ( $verdiff ) {
	    print join( "",
			"\t***EARLIEST CCTV ENTRY BEFORE VERIFICATION!!",
			"\n"
		);
	}
	if ( $visdiff ) {
	    print join( "",
			"\t***EARLIEST CCTV ENTRY BEFORE VISUAL!!",
			"\n"
		);
	}
    }
    
    1;
}



sub parse_al_memo () {
    $_ = shift;
    my $res;
    my @blocks = ( $_ =~ /(.*)(J[NSEW]O)(.*)/g );
    @blocks = ( $_ =~ /(.*)(AT)(.*)/g ) if not @blocks;
    my ($f1dir,$f1net,$f1fac) = ( $blocks[0] =~ /([NSEW]+)B*[- ]([^\d]*?)[- ]*(\d+)/ );
    $res->{f1dir} = $f1dir;
    $res->{f1net} = $f1net;
    $res->{f1fac} = $f1fac;
    my ($f2dir,$f2net,$f2fac) = ( $blocks[2] =~ / ([NSEW]+)B*[- ]([^\d]*?)[- ]*(\d+)/ );
    $res->{relloc} = $blocks[1];
    $res->{f2dir} = $f2dir;
    $res->{f2net} = $f2net;
    $res->{f2fac} = $f2fac;
    my @xs = ( $blocks[2] =~ /\s*(.*?)[-,\.]/ );
    $res->{xs} = join( ":", @xs );
    my $xxs = join( " ", @xs );
    my ($f3dir,$f3net,$f3fac) = ( $xxs =~ / ([NSEW]+)B*[- ]([^\d]*?)[- ]*(\d+)/ );
    $res->{f3dir} = $f3dir;
    $res->{f3net} = $f3net;
    $res->{f3fac} = $f3fac;
    return $res;
}


sub process_xs () {
    $_ = shift;
    my @parts = split( /\s+/, $_ );
    my $prefix = '';
    my $roadtype = '';
    $_ = $parts[ $#parts ];
    if ( /^PKWY$/ ||
	 /^RD$/ ||
	 /^ROAD$/ ||
	 /^AVE$/ ||
	 /^ST$/ ||
	 /^AV$/ ||
	 /^BLVD$/ ||
	 /^BL$/ ||
	 /^DR$/ ||
	 /^HWY/
	) {
	# last is road type, pop it
	$roadtype = pop @parts;
    }
    $_ = join( ' ', @parts );
    /CAMINO DE/ && do { $prefix = join( ' ', shift @parts, shift @parts ); };
    (/AVENIDA/ || /AVNDA/ || /AVENDIA/ ) && do { $prefix = shift @parts; };
    return [ join( ' ', @parts ), $prefix, $roadtype ];	
}
