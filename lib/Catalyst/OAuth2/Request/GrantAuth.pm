package Catalyst::OAuth2::Request::GrantAuth;
use Moose;

with 'Catalyst::OAuth2';

has approved => (isa => 'Bool', is => 'rw', default => 0);
has code => (is => 'ro', required => 1);

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

  my $store  = $self->client_store;
  my $client = $store->find( $self->client_id )
    or return {
    error             => 'unauthorized_client',
    error_description => 'the client identified by '
      . $self->client_id
      . ' is not authorized to access this resource'
  };

  my $code = $client->find_code($self->code);
  $code->activate if $self->approved;
  $q{code} = $code->as_string;

  return \%q;
}

sub next_action_uri {
  my($self, $controller, $c) = @_;
  $c->req->oauth2->redirect_uri;
}

1;
