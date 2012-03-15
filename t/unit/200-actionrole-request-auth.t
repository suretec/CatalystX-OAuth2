use strictures 1;
use Test::More;
use Test::Exception;
use Plack::Test;
use HTTP::Request::Common;
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
  my $uri = URI->new('/request');
  $uri->query_form(
    { response_type => 'code',
      client_id     => 'foo',
      state         => 'bar',
      redirect_uri  => '/client/foo'
    }
  );
  my $c = $mock->( GET $uri);
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

sub mock_context {
  my ($class) = @_;
  sub {
    my ($req) = @_;
    my $c;
    test_psgi app => sub {
      my $env = shift;
      $c = $class->prepare( env => $env, response_cb => sub { } );
      return [ 200, [ 'Content-type' => 'text/plain' ], ['Created mock OK'] ];
      },
      client => sub {
      my $cb = shift;
      $cb->($req);
      };
    return $c;
    }
}

done_testing();
