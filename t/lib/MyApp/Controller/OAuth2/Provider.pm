package MyApp::Controller::OAuth2::Provider;
use Moose;

BEGIN { extends 'Catalyst::Controller' }

with 'Catalyst::OAuth2::Controller::Role::Provider';

sub request : Chained('/') Args(0) Does('OAuth2::RequestAuth') {
  my ( $self, $c ) = @_;

  my $oauth2 = $c->req->oauth2;

  $oauth2->client_is_valid(1)
    if $c->authenticate( $c->req->body_parameters, 'client' );

  $c->user_exists and $oauth2->user_is_valid(1)
    or $c->detach('/passthrulogin');

}

=pod

sub grant : Does('OAuth2::GrantAuth') {
  my ( $self, $c ) = @_;

  my $oauth2 = $c->req->oauth2;

  my $scopes = $c->req->query_parameters->{granted_scopes};

  $oauth2->grant_scopes($scopes);
}

sub token : Does('OAuth2::AuthToken::ViaAuthGrant') {
}

sub refresh : Does('OAuth2::AuthToken::ViaRefreshToken') {
}

=cut

1;
