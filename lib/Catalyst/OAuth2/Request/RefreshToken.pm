package Catalyst::OAuth2::Request::RefreshToken;
use Moose;
use URI;
with 'Catalyst::OAuth2';

# ABSTRACT: The oauth2 refresh token

has grant_type    => ( is => 'ro', required => 1 );
has refresh_token => ( is => 'ro', required => 1 );

around _params => sub { shift->(@_), qw(grant_type refresh_token) };

sub _build_query_parameters {
  my ($self) = @_;

  my $code = $self->store->find_code_from_refresh( $self->refresh_token )
    or return {
    error             => 'invalid_grant',
    error_description => 'The provided authorization grant '
      . 'is invalid, expired, revoked, does not match the '
      . 'redirection URI used in the authorization request, '
      . 'or was issued to another client.'
    };

  my $token =
    $self->store->create_access_token_from_refresh( $self->refresh_token );
  return {
    access_token => $token->as_string,
    token_type   => $token->type,
    expires_in   => $token->expires_in
  };
}

1;
