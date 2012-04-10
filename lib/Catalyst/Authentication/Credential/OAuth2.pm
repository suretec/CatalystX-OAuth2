package Catalyst::Authentication::Credential::OAuth2;
use Moose;
use MooseX::Types::Common::String qw(NonEmptySimpleStr);
use LWP::UserAgent;
use JSON::Any;

has [qw(grant_uri token_uri client_id client_secret)] => (
  is       => 'ro',
  isa      => NonEmptySimpleStr,
  required => 1,
);

has ua => ( is => 'ro', default => sub { LWP::UserAgent->new } );

sub authenticate {
  my ( $self, $ctx, $realm, $auth_info ) = @_;
  my $callback_uri = $self->_build_callback_uri($ctx);

  unless ( defined( my $code = $ctx->request->params->{code} ) ) {
    my $auth_url = $self->extend_permissions( $callback_uri, $auth_info );
    $ctx->response->redirect($auth_url);

    return;
  } else {
    my $token = $self->request_access_token($callback_uri, $code, $auth_info);
    die 'Error validating verification code' unless $token;
    return $realm->find_user( { token => $token->{access_token}, }, $ctx );
  }
}

sub _build_callback_uri {
  my ( $self, $ctx ) = @_;
  my $uri = $ctx->request->uri->clone;
  $uri->query(undef);
  return $uri;
}

sub extend_permissions {
  my ( $self, $callback_uri, $auth_info ) = @_;
  my $uri   = URI->new( $self->grant_uri );
  my $query = {
    response_type => 'code',
    client_id     => $self->client_id,
    redirect_uri  => $callback_uri
  };
  $query->{state} = $auth_info->{state} if exists $auth_info->{state};
  $uri->query_form($query);
  return $uri;
}

my $j = JSON::Any->new;

sub request_access_token {
  my ( $self, $callback_uri, $code, $auth_info ) = @_;
  my $uri   = URI->new( $self->token_uri );
  my $query = {
    client_id    => $self->client_id,
    redirect_uri => $callback_uri,
    code         => $code
  };
  $query->{state} = $auth_info->{state} if exists $auth_info->{state};
  $uri->query_form($query);
  my $response = $self->ua->get($uri);
  return unless $response->is_success;
  return $j->jsonToObj($response->decoded_content);
}

1;
