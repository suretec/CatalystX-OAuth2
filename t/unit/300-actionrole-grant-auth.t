use strictures 1;
use Test::More;

use HTTP::Request::Common;
use lib 't/lib';
use CatalystX::Test::MockContext;

my $mock = mock_context('MyApp');

{
  my $uri = URI->new('/grant');
  $uri->query_form(
    { response_type   => 'code',
      client_id       => 'foo',
      state           => 'bar',
      redirect_uri    => '/client/foo',
      code            => 'foocode'
    }
  );
  my $c = $mock->( GET $uri );
  $c->dispatch;
  is_deeply( $c->error, [], 'dispatches to request action cleanly' );
  is( $c->res->body, undef, q{doesn't produce warning} );
  ok( $c->req->can('oauth2'),
    "installs oauth2 accessors if request is valid" );
  ok( Moose::Util::does_role( $c->req, 'Catalyst::OAuth2::Request' ) );
  my $res    = $c->res;
  my $client = $c->controller->client_store($c)->find('foo');
  is( $res->location,
    $c->controller->action_for('request')
      ->next_action_uri( $c->controller, $c ) );
  is( $res->status, 302 );
}


done_testing();
