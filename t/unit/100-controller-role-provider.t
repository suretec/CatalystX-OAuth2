use strictures 1;
use Test::More;
use Test::Exception;
use Plack::Test;
use HTTP::Request::Common;

use lib 't/lib';
use MyApp;

my $ctl = MyApp->controller('OAuth2::Provider');
lives_ok { $ctl->check_provider_actions };
is( $ctl->_request_auth_action, $ctl->action_for('request') );
is( $ctl->_get_auth_token_via_auth_grant_action, $ctl->action_for('grant') );

package MyApp::Mock::Controller;
use Moose;

BEGIN { extends 'Catalyst::Controller' }

with 'Catalyst::OAuth2::Controller::Role::Provider';

around check_provider_actions => sub {
  die qq{yo, I'm dead dawg};
};

package main;

{

  my $mock = mock_context('MyApp');
  my $c    = $mock->( GET '/request' );

  throws_ok {
    MyApp::Mock::Controller->COMPONENT( MyApp => $c, {} )->register_actions($c);
  }
  qr/yo, I'm dead dawg/,
    'provider actions checked when running register_actions';
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
