use strictures 1;
use Test::More;
use Test::Exception;
use Plack::Test;
use HTTP::Request::Common;
use CatalystX::Test::MockContext;
use URI;
use Moose::Util;

use lib 't/lib';
use MyApp;

my $ctl  = MyApp->controller('OAuth2::Provider');
my $mock = mock_context('MyApp');

{
  my $c = $mock->( GET '/request' );
  ok( !$c->req->can('oauth2'),
    "doesn't install oauth2 accessors before the dispatch" );
  ok( !Moose::Util::does_role( $c->req, 'Catalyst::OAuth2::Request' ) );
  $c->dispatch;
  is(
    $c->res->body,
    'warning: response_type/client_id invalid or missing',
    'displays warning to resource owner'
  );
  is_deeply( $c->error, [], 'dispatches to request action cleanly' );
  ok( !$c->req->can('oauth2'),
    "doesn't install oauth2 accessors if request isn't valid" );
  ok( !Moose::Util::does_role( $c->req, 'Catalyst::OAuth2::Request' ) );
}

{
  my $uri   = URI->new('/request');
  my $query = {
    response_type => 'code',
    client_id     => 'foo',
    state         => 'bar',
    redirect_uri  => '/client/foo'
  };

  $uri->query_form($query);
  my $c = $mock->( GET $uri );
  $c->dispatch;
  is_deeply( $c->error, [], 'dispatches to request action cleanly' );
  is( $c->res->body, undef, q{doesn't produce warning} );
  ok( $c->req->can('oauth2'),
    "installs oauth2 accessors if request is valid" );
  ok( Moose::Util::does_role( $c->req, 'Catalyst::OAuth2::Request' ) );
  my $res    = $c->res;
  my $client = $c->controller->client_store($c)->find('foo');
  ok( my $redirect = $c->req->oauth2->next_action_uri($c->controller, $c) );
  is( $res->location, $redirect, 'redirects to the correct action' );
  is_deeply( { $redirect->query_form }, { %$query, code => 'foocode' } );
  is( $res->status, 302 );
}

done_testing();
