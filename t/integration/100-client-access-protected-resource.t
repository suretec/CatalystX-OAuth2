use strictures 1;
use Test::More;
use lib 't/lib';
use AuthServer;
use ClientApp;

#use LWP::UserAgent::Plack;

my $auth_app = AuthServer->psgi_app;
my $main_app = ClientApp->psgi_app;
my $app      = sub {
  for ( $_[0]->{SERVER_NAME} ) {
    if   ( /authserver/ || /resourceserver/ ) { return &$auth_app }
    else                                      { return &$main_app }
  }
};

my $mech = $Catalyst::OAuth2::Client::UA =
  LWP::UserAgent::Plack->new( app => $app );

my $res = $mech->get('http://localhost/gold');

is( $res->content, '' );

$res = $mech->get('http://localhost/auth');

is( $res->content, 'auth ok' );

$res = $mech->get('http://localhost/lead');
is( $res->content, 'ok', 'fetch non-protected resource' );

$res = $mech->get('http://localhost/gold');
ok( $res->is_success );
is( $res->content, 'gold' );

done_testing();
