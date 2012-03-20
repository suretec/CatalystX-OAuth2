package Catalyst::OAuth2;
use Moose::Role;

# ABSTRACT: OAuth2 services for Catalyst

requires '_build_query_parameters';

# spec isn't clear re missing endpoint uris, being strict for now
has redirect_uri  => ( is => 'ro', required => 1 );

has client_store => (
  is        => 'rw',
  does      => 'Catalyst::OAuth2::ClientStore',
  init_arg  => undef,
  predicate => 'has_store'
);

has query_parameters => ( is => 'rw', init_arg => undef, lazy_build => 1 );

sub _params {qw(response_type redirect_uri scope state client_id)}

sub BUILD {
  my ( $self, $args ) = @_;
  delete @{$args}{ $self->_params() };
  if ( my @extra = keys %$args ) {
    $self->query_parameters(
      { error             => 'invalid_request',
        error_description => 'unrecognized parameters: '
          . join( ', ', @extra )
      }
    );
  }
}

1;
