package Catalyst::OAuth2::Request::RequestAuth;
use Moose;

has response_type => ( is => 'ro', required  => 1 );
has client_id     => ( is => 'ro', required  => 1 );
has redirect_uri  => ( is => 'ro', predicate => 'has_redirect_uri' );
has scope         => ( is => 'ro', predicate => 'has_scope' );
has state         => ( is => 'ro', predicate => 'has_state' );

has client_store => (
  is        => 'rw',
  does      => 'Catalyst::OAuth2::ClientStore',
  init_arg  => undef,
  predicate => 'has_store'
);

has query_parameters => ( is => 'ro', init_arg => undef, lazy_build => 1 );

sub _params {qw(response_type redirect_uri scope state client_id)}

sub BUILD {
  my ( $self, %args ) = @_;
  delete @args{ $self->_params() };
  if ( my @extra = keys %args ) {
    $self->query_parameters(
      { error             => 'invalid_request',
        error_description => 'unrecognized parameters: '
          . join( ', ', @extra )
      }
    );
  }
}

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

  $client->endpoint eq $self->redirect_uri
    or return {
    error => 'invalid_request',
    error_description =>
      'redirection_uri does not match the registerd client endpoint'
    };

  $q{code} = $client->create_code;

  return \%q;
}

1;
