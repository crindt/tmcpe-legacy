#!/usr/bin/perl -I./lib

use strict;
use IO::All;
use DBI;
use Getopt::Long;
use JSON;
use Geo::WKT;
use Carp;

use Date::Parse;
use Date::Calc qw( Delta_DHMS Time_to_Date Day_of_Week Day_of_Week_to_Text Mktime Localtime Add_Delta_DHMS );
use Date::Format;

use TMCPE::ActivityLog::LocationParser;

use SpatialVds::Schema;
use TMCPE::Schema;
use CT_AL::Schema;

use TMCPE::DelayComputation;

use Spreadsheet::WriteExcel;
use Spreadsheet::WriteExcel::Utility;

use warnings;
use English qw(-no_match_vars);
use Readonly;


my $spatialvds_db;
my $tmcpe_db;
my $actlog_db;

my $datefrom;
my $dateto;
my $onlylocated;
my $onlysigalert;
my $onlyverified;
my $only1097;
my $cad;
my $verbose;
my $computedelay;
my $writexls;
my $writejson = 1;
my $writedb;

GetOptions ("datefrom=s" => \$datefrom,
	    "dateto=s" => \$dateto,
	    "only-located" => \$onlylocated,
	    "only-sigalert" => \$onlysigalert,
	    "only-verified" => \$onlyverified,
	    "only-1097" => \$only1097,
	    "compute-delay" => \$computedelay,
	    "write-xls" => \$writexls,
	    "write-json" => \$writejson,
	    "write-db" => \$writedb,
	    "verbose" => \$verbose,
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

# object that uses a recdescent parser and the spatialvds database to
# obtain the nearest vdsid to the incident as determined by free-text
# written into the memo field.
my $lp = new TMCPE::ActivityLog::LocationParser();

my $incrs;
if ( $ARGV[0] ) {
    $incrs = $actlog_db->resultset('Incidents')->search( 
	{ cad=>$ARGV[0] },
	{ order_by => 'start_time asc' }
	);
} else {
    my $condition = {};

    my $datecond;
    $datecond->{'>='} = $datefrom if $datefrom;
    $datecond->{'<='} = $dateto   if $dateto;

    $condition->{start_time} = $datecond if $datecond;
    $condition->{cad} = { '-in' -> [ @ARGV ] } if $#ARGV>=0;
    
    $incrs = $actlog_db->resultset('Incidents')->search(
	$condition,
	{ order_by => 'start_time asc' }
	);
}


my $wb;
my $ws_summ;
my $summ_row;
my $wb_date_format;
if ( $writexls ) {
    $wb =  Spreadsheet::WriteExcel->new('incidents.xls'); 
    $wb->compatibility_mode();

    $wb_date_format = $wb->add_format( num_format => 'yyyy-mm-dd hh:mm' );

    $ws_summ = $wb->add_worksheet('Summary');
    $ws_summ->set_column( 'B:I', 20 );

    $ws_summ->write('A1', 'Incident Summary');
    $ws_summ->write( 3, 0, 'Sigalert?');
    $ws_summ->write( 3, 1, 'Incident');
    $ws_summ->write( 3, 2, 'First Call');
    $ws_summ->write( 3, 3, 'Verification');
    $ws_summ->write( 3, 4, 'On-scene');
    $ws_summ->write( 3, 5, 'Closed');
    $ws_summ->write( 3, 6, 'Verification Time');
    $ws_summ->write( 3, 7, 'Response Time');
    $ws_summ->write( 3, 8, 'Total Log Time');

    $summ_row = 4;
}

sub xls_time {
    my ( $t ) = @_;

    my $tt = str2time( $t );
    my $df = time2str( "%Y-%m-%dT%T", $tt );

    return $df;
}


while ( my $inc = $incrs->next ) 
{

    my $incdata = {
	cad => $inc->cad,
	start => $inc->start_time
    };

    print join ( " ",
		 "========================================",
		 "\nANALYZING",
		 $incdata->{cad},
		 "@",
		 $incdata->{start},
	)."\n" if $verbose;
    
    # OK, pull raw data
    my @logdetail = $actlog_db->resultset('Al')->search( 
	{ cad => $incdata->{cad} },
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
    my $inctype;
    my $city;
    my $locstr;
    my $incdet;
	
    my $first1097;

    foreach my $det ( @logdetail ) {

	if ( $det->unitin =~ /^\d+-/ ) {
	    push @{$unit->{$det->unitin}}, $det;
	};

	$first1097 = $det if ( ( $det->status =~ '10[-]*97' || $det->memo =~ '10[-]97' || $det->status =~ /FIRST UNIT/ )
			       && ( !$first1097
				    || str2time($det->ts) < str2time($first1097->ts) ) );


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

	# SOMETIMES, the operator pushes information about the incident in a somewhat standard format
	$_ = $det->activitysubject;
	$inctype = $det->memo if /INCIDENT\s+TYPE/;
	$city = $det->memo if /CITY/;
	$locstr = $det->memo if /RTE\/DIR\/LOCATION/;
	$incdet = $det->memo if /DESCRIPTION/;
    }

    my $start;
    my $end;
    my $locdata;

    if ( $firstcall ) {
	if ( $logdetail[0]->ts ne $firstcall->[0]->ts ) {
	    warn "\t***FIRST CALL AFTER FIRST LOG ENTRY\n" if $verbose;
	}
	if ( !$start || $firstcall->[0]->ts lt $start->ts ) 
	{
	    $start = $firstcall->[0];
	}
	if ( !$start || $logdetail[0]->ts lt $start->ts )
	{
	    $start = $logdetail[0];
	}
    }

    # No official start found, just use the first entry
    if ( !$start ) {
	$start = $logdetail[0];
    }

    # No official end found, just use the last entry
    if ( !$end ) {
	$end = $logdetail[$#logdetail];
    }

    if ( $start ) {
	print "\t\t===ASSUMED START IS " . $start->ts . "\n" if $verbose;

	$locdata = $lp->get_location( $locstr ) if $locstr;
	$locdata = $lp->get_location( $start->memo ) if !$locdata;

	if ( $locdata && $locdata->id ) {
	    print join( "", "\t\t===COMPUTED LOCATION IS APPROXIMATELY VDS #", $locdata->id, " [", $locdata->freeway_dir, "B ",$locdata->freeway_id, " @ ", $locdata->name, "]\n" ) if $verbose;
	} else {
	    print "\t\t***COULDN'T INFER LOCATION FROM LOGS***\n" if $verbose;
	    $locdata = undef;
	}
    } else {
	print "\t\t***!!!***NO START FOUND***!!!***\n" if $verbose;
    }

    
    my $firstver;
    my @cctvver;
    my @cctvvis;
    my @goodcctv;
    if ( $cctv && scalar( @{$cctv} ) ) {
	foreach my $cc ( @{$cctv} ) {
	    
	    # do some analysis here:
	    # INCIDENT VERIFICATION
	    if ( $cc->activitysubject eq 'VERIFICATION' ) {
		push @cctvver, $cc;
		$firstver = $cc 
		    if ( (not $firstver)
			 && ( $cc->status ne 'LANES CLEAR'
			      && $cc->status ne 'CMS OFF' 
			      && !($cc->memo =~ /LANES\s+CLEAR/
				   || $cc->memo =~ /LNS\s+CLEAR/ )
			 ));
	    }
	    if ( $cc->memo =~ /VISUAL/i ) {
		push @cctvvis, $cc;
	    }
	    if ( not ( $cc->status =~ /FAIL/ ) 
		 && not ( $cc->status =~ /PROB/ ) ) {
		push @goodcctv, $cc;
	    }
	}
    }


    if ( ( !$onlylocated || $locdata ) &&
	 ( !$onlysigalert || ( $sigalert && @{$sigalert} ) ) &&
	 ( !$onlyverified || $firstver ) &&
	 ( !$only1097 || $first1097 )
	) {

	print join ( " ",
		     "========================================",
		     "\nANALYZED",
		     $incdata->{cad},
		     "@",
		     $incdata->{start},
	    )."\n";
	
	foreach my $det ( @logdetail  ) {
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
	}

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
	}
	
	if ( $start ) {
	    print "\t\t===ASSUMED START IS " . $start->ts . "\n";
	    if ( $locdata ) {
		print join( "", "\t\t===COMPUTED LOCATION IS APPROXIMATELY VDS #", $locdata->id, " [", $locdata->freeway_dir, "B ",$locdata->freeway_id, " @ ", $locdata->name, "]\n" );
	    } else {
		print "\t\t***COULDN'T INFER LOCATION FROM LOGS***\n";
		$locdata = undef;
	    }
	}


	if ( $sigalert ) {
	    my @sa = @{$sigalert};
	    
	    # CHECK FOR VALIDITY
	    my $valid = 0;
	    my $sastart;
	    my $saend;
	    if ( ( $sa[0]->activitysubject eq 'SIGALERT BEGIN'
		   || $sa[0]->memo =~ /SIGALERT.*ISSUE/ 
#	     || $sa[0]->memo =~ /FAXED\s+SIGALERT/ 
		 )
		 && ($sa[$#sa]->activitysubject eq 'SIGALERT END' 
		     || $sa[$#sa]->memo =~ /SIGALERT.*CANCEL/
		     || $sa[$#sa]->memo =~ /SIGALERT.*1022/)
		) {
		
		my @tt = Localtime(str2time( join( ' ', $sa[0]->stampdate, $sa[0]->stamptime ) ));
		$sastart = Mktime(@tt[0..5]);
		@tt = Localtime(str2time( join( ' ', $sa[$#sa]->stampdate, $sa[$#sa]->stamptime ) ));
		$saend   = Mktime(@tt[0..5]);
		my @dur = Delta_DHMS( Time_to_Date( $sastart ), Time_to_Date( $saend ) );
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
		my @estend = Add_Delta_DHMS( Time_to_Date( $sastart), 0, 0, $estdur, 0 );
		my @esterr = Delta_DHMS( Time_to_Date( $saend ), @estend );
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
			);
		}
	    }
	}
	
	my @cctvver;
	my @cctvvis;
	my @goodcctv;
	if ( $cctv && scalar( @{$cctv} ) ) {
	    print "CCTV:\n";
#	    foreach my $cc ( @{$cctv} ) {
#		print join( "",
#			    "\t\t",
#			    join( " :: ",
#				  $cc->ts,
#				  $cc->status,
#				  $cc->activitysubject,
#				  $cc->memo ),
#			    "\n"
#		    );
#	    }
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

	if ( $computedelay && $locdata ) {


########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
	    
	    my $dc = new TMCPE::DelayComputation();
	    $dc->cad( $incdata->{cad} );
	    $dc->facil( $locdata->freeway_id );
	    $dc->dir( $locdata->freeway_dir );
	    $dc->pm( $locdata->abs_pm );
	    $dc->vdsid( $locdata->id );
	    $dc->logstart( $start->ts );
	    $dc->logend( $end->ts );

	    $dc->compute_delay;

	    $dc->write_json( '.' ) if $writejson;
	    $dc->write_to_db() if $writedb;
	    
	}

	if ( $writexls ) {

	    # add row to summary table
	    $ws_summ->write( $summ_row, 0, "***" ) if ( $sigalert && @{$sigalert} );
	    $ws_summ->write( $summ_row, 1, $incdata->{cad} );
	    $ws_summ->write_date_time( $summ_row, 2, xls_time( $start->ts ), $wb_date_format);    # first call
	    $ws_summ->write_date_time( $summ_row, 3, xls_time( $firstver->ts ), $wb_date_format ) if $firstver;
	    $ws_summ->write_date_time( $summ_row, 4, xls_time( $first1097->ts ), $wb_date_format ) if $first1097;  # on-scene
	    $ws_summ->write_date_time( $summ_row, 5, xls_time( $end->ts ), $wb_date_format );         # closed

	    # $ws_summ->write_formula( $summ_row, 6, 
	    # 			     join( '',
	    # 				   '=int((',
	    # 				   xl_rowcol_to_cell( $summ_row, 3 ),
	    # 				   '-',
	    # 				   xl_rowcol_to_cell( $summ_row, 2 ),
	    # 				   ')*24*60)' )
	    # 	);

	    # $ws_summ->write_formula( $summ_row, 7, 
	    # 			     join( '',
	    # 				   '=int((',
	    # 				   xl_rowcol_to_cell( $summ_row, 4 ),
	    # 				   '-',
	    # 				   xl_rowcol_to_cell( $summ_row, 3 ),
	    # 				   ')*24*60)' )
	    # 	);
	    # $ws_summ->write_formula( $summ_row, 8, 
	    # 			     join( '',
	    # 				   '=int((',
	    # 				   xl_rowcol_to_cell( $summ_row, 5 ),
	    # 				   '-',
	    # 				   xl_rowcol_to_cell( $summ_row, 2 ),
	    # 				   ')*24*60)' )
	    # 	);

	    $summ_row++;

	    # add detail worksheet
	    my $ws = $wb->add_worksheet( $incdata->{cad});

	    # formatting
	    $ws->set_column( 'B:B', 20 );
	    $ws->set_column( 'C:C', 12 );
	    $ws->set_column( 'D:D', 12 );
	    $ws->set_column( 'F:F', 20 );
	    $ws->set_column( 'G:G', 20 );
	    $ws->set_column( 'H:H', 20 );

	    $ws->write( 'A1', join( "", $incdata->{cad}, " detail" ) );
	    $ws->write( 3, 1, join( "", "Inferred Location: " ) );
	    $ws->write( 3, 2, join( "", $locdata->id ) );
	    $ws->write( 3, 3, join( "", join( "", $locdata->freeway_dir, 'B-', $locdata->freeway_id, ' @ ', $locdata->name, " [abs_pm: ", $locdata->abs_pm,"]" ) ));

	    my $col = 1;
	    my @cols1 = qw / ts unitin unitout via / ; # device_number device_extra device_direction device_fwy device_name
	    my @cols2 = qw / status activitysubject memo /;  
	    map { $ws->write( 7, $col++, $_ ) } @cols1;
	    $ws->write( 7, $col++, "device" );
	    map { $ws->write( 7, $col++, $_ ) } @cols2;
	    my $row = 8;
	    shift @cols1; # we'll write the timestamp manually
	    foreach my $det ( @logdetail ) {
		$col = 1;
		my $tt = str2time( $det->ts );
		my $df = time2str( "%Y-%m-%dT%T", $tt );
		$ws->write_date_time( $row, $col++,$df, $wb_date_format );
		map { $ws->write( $row, $col++, eval { $det->$_ } ) } @cols1;
		$ws->write( $row, $col, join( "", $det->device_number, ": ", grep { defined $_ } ( $det->device_direction, "B-", $det->device_fwy, " @ ", $det->device_name ) ) ) if $det->device_number;
		$col++;
		map { $ws->write( $row, $col++, eval { $det->$_ } ) } @cols2;
		$row++;
	    }
	}
    }
}

