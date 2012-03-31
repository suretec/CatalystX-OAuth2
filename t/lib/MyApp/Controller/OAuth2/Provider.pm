package MyApp::Controller::OAuth2::Provider;
use Moose;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

use URI;

with 'Catalyst::OAuth2::Controller::Role::Provider';

__PACKAGE__->config(
  store => {
    class => 'DBIC',
    client_model => 'DB::Client'
  }
);

sub request : Chained('/') Args(0) Does('OAuth2::RequestAuth') {}

sub grant : Chained('/') Args(0) Does('OAuth2::GrantAuth') {
  my ( $self, $c ) = @_;

  my $oauth2 = $c->req->oauth2;

  $c->user_exists and $oauth2->user_is_valid(1)
    or $c->detach('/passthrulogin');
}

sub token : Chained('/') Args(0) Does('OAuth2::AuthToken::ViaAuthGrant') {}

sub refresh : Chained('/') Args(0) Does('OAuth2::AuthToken::ViaRefreshToken') {}


1;
