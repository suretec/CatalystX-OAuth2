package Catalyst::ActionRole::OAuth2::ProtectedResource;
use Moose::Role;

before execute => sub {
  my ( $self, $controller, $c ) = @_;
  $c->res->status(401), $c->detach unless $c->user_exists;
  my $client = $c->user;

  my $auth = $c->req->header('Authorization')
    or $c->res->status(401), $c->detach;
  my($type, $token) = split ' ', $auth;

  $c->res->status(401), $c->detach
    unless $controller->store->verify_client_token($client->id, $token);
};

1;
