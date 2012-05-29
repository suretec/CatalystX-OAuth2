package Catalyst::ActionRole::OAuth2::ProtectedResource;
use Moose::Role;

# ABSTRACT: Resource endpoint for OAuth2 authentication flows

=head1 SYNOPSIS

    package AuthServer::Controller::OAuth2::Resource;
    use Moose;

    BEGIN { extends 'Catalyst::Controller::ActionRole' }

    with 'CatalystX::OAuth2::Controller::Role::WithStore';

    __PACKAGE__->config(
      store => {
        class => 'DBIC',
        client_model => 'DB::Client'
      }
    );

    sub resource : Chained('/') Args(0) Does('OAuth2::ProtectedResource') {
      my ( $self, $c ) = @_;
      $c->res->body( 'my protected resource' );
    }

=head1 DESCRIPTION

This action role implements an arbitrary resource endpoint to be protected by
the authorization flow. Clients will only be able to access this resource if
they provide a valid access token. The action body should be customized like a
regular action.

=cut

before execute => sub {
  my ( $self, $controller, $c ) = @_;

  $c->res->status(401), $c->detach
    unless $c->user_exists;
  my $client = $c->user;

  my $auth = $c->req->header('Authorization')
    or $c->res->status(401), $c->detach;
  my ( $type, $token ) = split ' ', $auth;

  $c->res->status(401), $c->detach
    unless defined($token)
      && length($token)
      && $controller->store->verify_client_token( $client->id, $token );
};

1;
