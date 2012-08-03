package Catalyst::ActionRole::OAuth2::ProtectedResource;
use Moose::Role;
use CatalystX::OAuth2::Request::ProtectedResource;

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

with 'CatalystX::OAuth2::ActionRole::RequestInjector';

sub build_oauth2_request {
  my ( $self, $controller, $c ) = @_;

  my $auth = $c->req->header('Authorization')
    or $c->res->status(401), $c->detach;
  my ( $type, $token ) = split ' ', $auth;

  my $is_valid = defined($token)
    && length($token);

  if ( $is_valid
    and my $token_obj = $controller->store->verify_client_token($token) )
  {
    return CatalystX::OAuth2::Request::ProtectedResource->new(
      token => $token_obj );
  }
  $c->res->status(401);
  $c->detach;
}

1;
