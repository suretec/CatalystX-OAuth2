package Catalyst::ActionRole::OAuth2::RequestAuth;
use Moose::Role;
use Try::Tiny;
use URI;
use Catalyst::OAuth2::Request::RequestAuth;

# ABSTRACT: Authorization grant endpoint for OAuth2 authentication flows

=head1 SYNOPSIS

    package AuthServer::Controller::OAuth2::Provider;
    use Moose;
    BEGIN { extends 'Catalyst::Controller::ActionRole' }

    with 'Catalyst::OAuth2::Controller::Role::Provider';

    __PACKAGE__->config(
      store => {
        class => 'DBIC',
        client_model => 'DB::Client'
      }
    );

    sub request : Chained('/') Args(0) Does('OAuth2::RequestAuth') {}

=head1 DESCRIPTION

This action role implements the initial endpoint that triggers the
authorization grant flow. It generates an inactive authorization code
redirects to the next action in the workflow if all parameters are valid. The
authorization code is used to verify the validity of the arguments in the
subsequent request of the flow and prevent users of this library from creating
potentially unsafe front-end forms for user confirmation of the authorization.

=cut

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
