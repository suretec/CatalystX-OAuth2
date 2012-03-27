package Catalyst::ActionRole::OAuth2::AuthToken::ViaRefreshToken;
use Moose::Role;
use Try::Tiny;
use Catalyst::OAuth2::Request::RefreshToken;

with 'Catalyst::OAuth2::ActionRole::Token';

sub build_oauth2_request {
  my ( $self, $controller, $c ) = @_;

  my $store = $controller->store;
  my $req;

  try {
    $req = Catalyst::OAuth2::Request::RefreshToken->new(
      %{ $c->req->query_parameters } );
    $req->store($store);
  }
  catch {
    # need to figure out a better way, but this will do for now
    $c->res->body('warning: response_type/client_id invalid or missing');

    $c->detach;
  };

  return $req;
}

1;
