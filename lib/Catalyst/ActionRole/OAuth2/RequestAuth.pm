package Catalyst::ActionRole::OAuth2::RequestAuth;
use Moose::Role;
use Try::Tiny;
use URI;
use Catalyst::OAuth2::Request::RequestAuth;

with 'Catalyst::OAuth2::ActionRole::Grant';

sub build_oauth2_request {
  my ( $self, $controller, $c ) = @_;

  my $store = $controller->client_store($c);
  my $req;
  try {
    $req = Catalyst::OAuth2::Request::RequestAuth->new(
      %{ $c->req->query_parameters } );
    $req->client_store($store);
  }
  catch {

    # need to figure out a better way, but this will do for now
    $c->res->body('warning: response_type/client_id invalid or missing');

    $c->detach;
  };
  return $req;
}

1;
