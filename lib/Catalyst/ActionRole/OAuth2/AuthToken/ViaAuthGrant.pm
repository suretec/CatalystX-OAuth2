package Catalyst::ActionRole::OAuth2::AuthToken::ViaAuthGrant;
use Moose::Role;
use Try::Tiny;
use CatalystX::OAuth2::Request::AuthToken;

# ABSTRACT: Authorization token provider endpoint for OAuth2 authentication flows

=head1 SYNOPSIS

    package AuthServer::Controller::OAuth2::Provider;
    use Moose;

    BEGIN { extends 'Catalyst::Controller::ActionRole' }

    use URI;

    with 'CatalystX::OAuth2::Controller::Role::Provider';

    __PACKAGE__->config(
      store => {
        class => 'DBIC',
        client_model => 'DB::Client'
      }
    );

    sub token : Chained('/') Args(0) Does('OAuth2::AuthToken::ViaAuthGrant') {}

    1;

=head1 DESCRIPTION

This action role implements an endpoint that exchanges an authorization code
for an access token.

=cut

with 'CatalystX::OAuth2::ActionRole::Token';

sub build_oauth2_request {
  my ( $self, $controller, $c ) = @_;

  my $store = $controller->store;
  my $req;

  try {
    $req = CatalystX::OAuth2::Request::AuthToken->new(
      %{ $c->req->query_parameters } );
    $req->store($store);
  }
  catch {
    $c->log->error($_);
    # need to figure out a better way, but this will do for now
    $c->res->body('warning: response_type/client_id invalid or missing');

    $c->detach;
  };

  return $req;
}

1;
