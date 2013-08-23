#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Betting::Toolkit::Client' ) || print "Bail out!\n";
}

diag( "Testing App::Betting::Toolkit::Client $App::Betting::Toolkit::Client::VERSION, Perl $], $^X" );
