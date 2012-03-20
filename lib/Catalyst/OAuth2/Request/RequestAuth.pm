package Catalyst::OAuth2::Request::RequestAuth;
use Moose;

with 'Catalyst::OAuth2::Grant';

sub _build_query_parameters {
  my ($self) = @_;

  my %q = $self->has_state ? ( state => $self->state ) : ();

  $self->response_type eq 'code'
    or return {
    error             => 'unsuported_response_type',
    error_description => 'this server does not support "'
      . $self->response_type
      . "' as a method for obtaining an authorization code",
    %q
    };

  $q{response_type} = $self->response_type;

  my $store  = $self->client_store;
  my $client = $store->find( $self->client_id )
    or return {
    error             => 'unauthorized_client',
    error_description => 'the client identified by '
      . $self->client_id
      . ' is not authorized to access this resource'
    };

  $q{client_id} = $self->client_id;

  $client->endpoint eq $self->redirect_uri
    or return {
    error => 'invalid_request',
    error_description =>
      'redirection_uri does not match the registerd client endpoint'
    };

  $q{redirect_uri} = $self->redirect_uri;

  my $code = $client->create_code;
  $q{code} = $code->as_string;

  return \%q;
}

sub next_action_uri {
  my ( $self, $controller, $c ) = @_;
  $c->uri_for( $controller->_get_auth_token_via_auth_grant_action,
    $self->query_parameters );
}

1;
