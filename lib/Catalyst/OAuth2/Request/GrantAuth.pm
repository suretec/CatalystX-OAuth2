package Catalyst::OAuth2::Request::GrantAuth;
use Moose;
use URI;

with 'Catalyst::OAuth2::Grant';

has user_is_valid => (isa => 'Bool', is => 'rw', default => 0);
has approved => (isa => 'Bool', is => 'rw', default => 0);
has code => (is => 'ro', required => 1);
has granted_scopes => (isa => 'ArrayRef', is => 'rw', default => sub {[]});

around _params => sub {
  my $super = shift;
  $super->(@_), qw(code granted_scopes);
};

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
  my $uri = URI->new($c->req->oauth2->redirect_uri);
  $uri->query_form($self->query_parameters);
  return $uri;
}

1;
