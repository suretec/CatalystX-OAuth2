package MyApp::Controller::OAuth2::Provider;
use Moose;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

use URI;

with 'Catalyst::OAuth2::Controller::Role::Provider';

# my $client = $store->find($string);
# my $endpoint = $client->endpoint;
# my $code = $client->create_code;
# my $code = $client->find_code($string);
# $code->as_string;
# $code->activate;
# $code->deactivate;
sub client_store {
  my($self, $c) = @_;
  return $c->model('DB::OAuth2::Client');
}

sub request : Chained('/') Args(0) Does('OAuth2::RequestAuth') {}

sub grant : Does('OAuth2::GrantAuth') {
  my ( $self, $c ) = @_;

  my $oauth2 = $c->req->oauth2;

  my $scopes = $c->req->query_parameters->{granted_scopes};

  $oauth2->client_is_valid(1)
    if $c->authenticate( $c->req->body_parameters, 'client' );

  $c->user_exists and $oauth2->user_is_valid(1)
    or $c->detach('/passthrulogin');

  $oauth2->grant_scopes($scopes);
}

=pod

sub token : Does('OAuth2::AuthToken::ViaAuthGrant') {
}

sub refresh : Does('OAuth2::AuthToken::ViaRefreshToken') {
}

=cut


1;