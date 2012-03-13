use strictures 1;
use Test::More;
use Test::Exception;
use Plack::Test;
use HTTP::Request::Common;
use Moose::Util;

use lib 't/lib';
use MyApp;

my $ctl  = MyApp->controller('OAuth2::Provider');
my $mock = mock_context('MyApp');

{
  my $c = $mock->( GET '/request' );
  ok(!$c->req->can('oauth2'), "doesn't install oauth2 accessors before the dispatch");
  ok(!Moose::Util::does_role($c->req, 'Catalyst::OAuth2::Request'));
  $c->dispatch;
  is_deeply($c->error, [], 'dispatches to request action cleanly');
  ok($c->req->can('oauth2'), "installs oauth2 accessors for the dispatch");
  ok(Moose::Util::does_role($c->req, 'Catalyst::OAuth2::Request'));
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
