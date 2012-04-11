package Catalyst::ActionRole::OAuth2::RequestAuth;
use Moose::Role;
use Try::Tiny;
use URI;
use Catalyst::OAuth2::Request::RequestAuth;

with 'Catalyst::OAuth2::ActionRole::Grant';

has enable_access_secret => ( isa => 'Bool', is => 'ro', default => 0 );

sub build_oauth2_request {
  my ( $self, $controller, $c ) = @_;

  my $store = $controller->store;
  my $req;
  try {
    $req = Catalyst::OAuth2::Request::RequestAuth->new(
      %{ $c->req->query_parameters } );
    $req->enable_access_secret($self->enable_access_secret);
    $req->store($store);
  }
  catch {

    # need to figure out a better way, but this will do for now
    $c->res->body(qq{warning: response_type/client_id invalid or missing});

    $c->detach;
  };
  return $req;
}

1;
