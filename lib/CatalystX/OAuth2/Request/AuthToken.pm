package CatalystX::OAuth2::Request::AuthToken;
use Moose;
use URI;

with 'CatalystX::OAuth2';

# ABSTRACT: An oauth2 authentication token implementation

has grant_type => ( is => 'ro', required => 1 );
has code  => ( is => 'ro', required => 1 );

around _params => sub {shift->(@_), qw(code grant_type)};

sub _build_query_parameters {
  my ($self) = @_;

  my $code = $self->store->find_client_code( $self->code )
    or return {
    error             => 'invalid_grant',
    error_description => 'The provided authorization grant '
      . 'is invalid, expired, revoked, does not match the '
      . 'redirection URI used in the authorization request, '
      . 'or was issued to another client.'
    };

  my $token = $self->store->create_access_token($self->code);
  return {
    access_token => $token->as_string,
    token_type   => $token->type,
    expires_in   => $token->expires_in
  };
}

1;
