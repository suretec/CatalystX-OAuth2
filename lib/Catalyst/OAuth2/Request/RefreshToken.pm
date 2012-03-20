package Catalyst::OAuth2::Request::RefreshToken;
use Moose;
use URI;
with 'Catalyst::OAuth2';

has grant_type => ( is => 'ro', required => 1 );
has refresh_token  => ( is => 'ro', required => 1 );

around _params => sub {shift->(@_), qw(grant_type refresh_token)};

sub _build_query_parameters {
  my ($self) = @_;

  my $code = $self->client_store->find_refresh_token( $self->refresh_token )
    or return {
    error             => 'invalid_grant',
    error_description => 'The provided authorization grant '
      . 'is invalid, expired, revoked, does not match the '
      . 'redirection URI used in the authorization request, '
      . 'or was issued to another client.'
    };

  my $token = $code->create_token();
  return {
    access_token => $token->as_string,
    token_type   => $token->type,
    expires_in   => $token->expires_in
  };
}

1;
