#!/usr/bin/perl -I../data/actlog/lib

use Getopt::Long;
use Date::Calc qw/ Today Delta_Days /;

# Mail stuff
my $host = 'localhost';
my $port = 587;
my $user = undef;
my $pw = undef;
my $hello = 'localhost';
my $to = 'crindt@translab.its.uci.edu';
my $id = 'unspecified';
my $actloguser = undef;
my $actlogpassword = undef;
my $vdsuser = undef;
my $vdspassword = undef;
my $mail = undef;
my $vdscheckid = 1201044;  # the id of the vds to check in pems_5min
my $tmcpeuser = undef;
my $tmcpepassword = undef;

my $res = GetOptions(
    'host=s' => \$host,
    'port=i' => \$port,
    'user=s' => \$user,
    'password=s' => \$pw,
    'hello=s' => \$hello,
    'to=s' => \$to,
    'id=s' => \$id,
    'actlog-user=s' => \$actloguser,
    'actlog-password=s' => \$actlogpassword,
    'vds-user=s' => \$vdsuser,
    'vds-password=s' => \$vdspassword,
    'vds-checkid=i' => \$vdscheckid,
    'tmcpe-user=s' => \$tmcpeuser,
    'tmcpe-password=s' => \$tmcpepassword,
    'mail=s' => \$mail,
    );


# Check whether datasets are getting updated

# we pull the schema's in from the data/actlog directory
use Caltrans::ActivityLog::Schema;
use SpatialVds::Schema;
use TMCPE::Schema;


my $d12 = Caltrans::ActivityLog::Schema->connect(
    "dbi:mysql:dbname=actlog;host=trantor.its.uci.edu;port=3366",
    $actloguser, $actlogpassword,
    { AutoCommit => 1 },
    );

my $vdsdb = SpatialVds::Schema->connect(
    "dbi:Pg:dbname=spatialvds;host=localhost",
    $vdsuser, $vdspassword,
    { AutoCommit => 1 },
    );

my $tmcpe = TMCPE::Schema->connect(
    join("", "dbi:Pg:dbname=","tmcpe_test",";","host=","localhost"),
    $tmcpeuser, $tmcpepassword,
    { AutoCommit => 1, db_Schema => 'tmcpe' },
    );


my @today = Today();

# Check for most recent Activity Log Data
my $rs = $d12->resultset( 'CtAlTransaction' )->search(
    undef,{ 
        order_by => 'keyfield desc',
        rows => 1
    });

my $rec = $rs->first();
my ( $d, $t ) = ( $rec->stampdate, $rec->stamptime );
my @last = split(/-/,$d);
my $actlogage = Delta_Days( @last, @today );


# Check for the most recent VDS data
$rs = $vdsdb->resultset( 'Pems5min')->search(
    { vdsid => $vdscheckid },
    { order_by => 'stamp desc',
      rows => 1
    });
$rec = $rs->first();
my ( $d, $t ) = split(' ', $rec->stamp );
@last = split(/-/, $d );
my $vdsage = Delta_Days( @last, @today );


# Check for the most recent incident analysis

$rs = $tmcpe->resultset( 'AllAnalyses')->search(
    undef,
    { order_by => 'start_time desc',
      rows => 1
    });
$rec = $rs->first();
my ( $d, $t ) = split(' ', $rec->start_time );
@last = split(/-/, $d );
my $tmcpeage = Delta_Days( @last, @today );


if ( $actlogage > 1 || $vdsage > 1 ) {
    print "Activity log data is old ($actlogage days)\n" if $actlogage > 1;
    print "VDS data is old ($vdsage days)\n" if $vdsage > 1;
    print "TMCPE analysis data is old ($tmcpeage days)\n" if $tmcpeage > 1;

    if ( $mail ) {
        use Net::SMTP::TLS;
        use Email::Send;

        # Nothing found.  Notify the relevant parties

        my $mailer = new Net::SMTP::TLS(
            $host,
            Port => $port,
            User => $user,
            Password => $pw,
            Hello => $hello,
            );

        $mailer->mail($mail);
        $mailer->to($mail);
        $mailer->data;
        $mailer->datasend("From: $mail\n" );
        $mailer->datasend("Subject: TMCPE-related data is not up to date\n" );
        $mailer->datasend("\n" );
        $mailer->datasend("Activity log data is old ($actlogage days)\n") if $actlogage > 1;
        $mailer->datasend("VDS data is old ($vdsage days)\n") if $vdsage > 1;
        $mailer->datasend("TMCPE analysis data is old ($tmcpeage days)\n\n") if $tmcpeage > 1;

        $mailer->datasend("Please look into it\n" );
        $mailer->datasend("\n" );
        $mailer->datasend("Sent from $id\n" );
        $mailer->dataend();
        $mailer->quit();

        die "Error sending email: $@" if $@;
    }

    exit( 1 );

} else {
    print "Activity log data looks up to date\n";
}

1;





