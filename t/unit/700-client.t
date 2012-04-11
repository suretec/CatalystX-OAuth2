use strictures 1;
use Test::More;
use Test::MockObject;
use CatalystX::Test::MockContext;
use HTTP::Request::Common;
use JSON::Any;
use lib 't/lib';
use AuthServer;

use Catalyst::Authentication::Credential::OAuth2;

my $mock = mock_context('AuthServer');

{
  my $cred = Catalyst::Authentication::Credential::OAuth2->new(
    grant_uri     => 'http://server.foo/grant',
    token_uri     => 'http://server.foo/token',
    client_id     => 42,
    client_secret => 'foosecret'
  );
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

my $j = JSON::Any->new;

{
  my $ua       = Test::MockObject->new;
  my $res      = Test::MockObject->new;
  my $tok_data = {
    access_token  => '2YotnFZFEjr1zCsicMWpAA',
    token_type    => "bearer",
    expires_in    => 3600,
    refresh_token => "tGzv3JOkF0XG5Qx2TlKWIA"
  };
  $res->set_true('is_success');
  $res->mock(
    decoded_content => sub {
      $j->objToJson($tok_data);
    }
  );
  $ua->mock( get => sub {$res} );
  my $uri   = URI->new('/');
  $uri->query_form( { code => 'foocode' } );
  my $c     = $mock->( GET $uri );
  my $realm = Test::MockObject->new;
  my $user  = Test::MockObject->new;
  $realm->mock( find_user => sub {$user} );

  my $cred = Catalyst::Authentication::Credential::OAuth2->new(
    grant_uri     => 'http://server.foo',
    token_uri     => 'http://server.foo/token',
    client_id     => 42,
    client_secret => 'foosecret',
    ua            => $ua
  );

  ok( $cred->authenticate( $c, $realm, {} ) );

  {
    my ( $name, $args ) = $realm->next_call;
    is( $name, 'find_user' );
    shift @$args; # remove $self
    is_deeply( $args, [{ token => $tok_data->{access_token}}, $c] );
    ok( !defined( $realm->next_call ) );
  }

}

done_testing();
