use strictures 1;
use Test::More;
use Test::MockObject;
use HTTP::Request::Common;
use CatalystX::Test::MockContext;

use lib 't/lib';
use MyApp;

use Catalyst::Authentication::Credential::OAuth2;

my $mock = mock_context('MyApp');

my $client = MyApp->model('DB::Client')->first;
my $cred   = Catalyst::Authentication::Credential::OAuth2->new(
  oauth_server_uri => 'http://server.foo',
  client_id        => $client->id,
  client_secret    => $client->access_secret
);

{
  my $c     = $mock->( GET '/' );
  my $realm = Test::MockObject->new;

  ok( !$cred->authenticate( $c, $realm, {} ) );

  ok( !defined( $realm->next_call ) );

  is( $c->res->status, 302 );

  my $callback_uri = $cred->_build_callback_uri($c);
  is( $callback_uri, 'http://localhost/' );

  my $extend_perms_uri = $cred->extend_permissions($callback_uri);

  is( $c->res->redirect, $extend_perms_uri );

}

done_testing();
